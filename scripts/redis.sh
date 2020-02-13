#!/bin/bash
set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/etc/tflog.out 2>&1

INIT_DNS="${name}0.${name}.${name}.oraclevcn.com"
NODE_DNS=$(hostname -f)
MASTER_PRIVATE_IP=$(host "$INIT_DNS" | awk '{ print $4 }')

PASSWORD=${password}
REDIS_VERSION="5.0.7"
REDIS_PORT=6379
REDIS_CONFIG_FILE=/etc/redis.conf

SENTINEL_PORT=26379
SENTINEL_CONFIG_FILE=/etc/sentinel.conf

# Setup firewall rules
firewall-offline-cmd  --zone=public --add-port=6379/tcp
firewall-offline-cmd  --zone=public --add-port=16379/tcp
systemctl restart firewalld

# Install wget and gcc
yum install -y wget gcc

# Download and compile Redis
wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar xvzf redis-$REDIS_VERSION.tar.gz
cd redis-$REDIS_VERSION
make install

cp ./redis.conf $REDIS_CONFIG_FILE

if [[ $INIT_DNS == $NODE_DNS ]]
then
  sed -i "s/^bind 127.0.0.1/bind $MASTER_PRIVATE_IP/g" $REDIS_CONFIG_FILE
  sed -i "s/^daemonize no/daemonize yes/g" $REDIS_CONFIG_FILE
  sed -i "s/^# requirepass foobared/requirepass $PASSWORD/g" $REDIS_CONFIG_FILE
  redis-server /etc/redis.conf
else
  sleep 60
  sed -i "s/^# masterauth <master-password>/masterauth $PASSWORD/g" $REDIS_CONFIG_FILE
  sed -i "s/^# replicaof <masterip> <masterport>/replicaof $MASTER_PRIVATE_IP $REDIS_PORT/g" $REDIS_CONFIG_FILE
  redis-server /etc/redis.conf
 fi

cat << EOF > $SENTINEL_CONFIG_FILE
port $SENTINEL_PORT
sentinel monitor $INIT_DNS $MASTER_PRIVATE_IP 6379 2
sentinel down-after-milliseconds $INIT_DNS 5000
sentinel failover-timeout $INIT_DNS 60000
sentinel parallel-syncs $INIT_DNS 1
EOF

sleep 30
redis-server /etc/sentinel.conf --sentinel