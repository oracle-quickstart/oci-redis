#!/bin/bash
set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/tflog.out 2>&1

REDIS_CONFIG_FILE=/etc/redis.conf
SENTINEL_CONFIG_FILE=/etc/sentinel.conf

# Setup firewall rules
firewall-offline-cmd  --zone=public --add-port=${redis_port1}/tcp
firewall-offline-cmd  --zone=public --add-port=${redis_port2}/tcp
firewall-offline-cmd  --zone=public --add-port=${sentinel_port}/tcp
systemctl restart firewalld

# Install wget and gcc
yum install -y wget gcc

# Download and compile Redis
wget http://download.redis.io/releases/redis-${redis_version}.tar.gz
tar xvzf redis-${redis_version}.tar.gz
cd redis-${redis_version}
make install

# Configure Sentinel
cat << EOF > $REDIS_CONFIG_FILE
port ${redis_port1}
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-slave-validity-factor 0
appendonly yes
requirepass ${redis_password}
masterauth ${redis_password}
EOF

# Configure Sentinel
cat << EOF > $SENTINEL_CONFIG_FILE
port ${sentinel_port}

sentinel monitor ${master1_fqdn} ${master1_private_ip} 6379 2
sentinel down-after-milliseconds ${master1_fqdn} 60000
sentinel failover-timeout ${master1_fqdn} 180000
sentinel parallel-syncs ${master1_fqdn} 1

sentinel monitor ${master2_fqdn} ${master2_private_ip} 6379 2
sentinel down-after-milliseconds ${master2_fqdn} 10000
sentinel failover-timeout ${master2_fqdn} 180000
sentinel parallel-syncs ${master2_fqdn} 1

sentinel monitor ${master3_fqdn} ${master3_private_ip} 6379 2
sentinel down-after-milliseconds ${master3_fqdn} 10000
sentinel failover-timeout ${master3_fqdn} 180000
sentinel parallel-syncs ${master3_fqdn} 1
EOF

sleep 30
#/usr/local/bin/redis-server $SENTINEL_CONFIG_FILE --sentinel --daemonize yes
#/usr/local/bin/redis-server $REDIS_CONFIG_FILE
#nohup /usr/local/bin/redis-server $SENTINEL_CONFIG_FILE --sentinel > /tmp/redis-server.log &
