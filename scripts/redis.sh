#!/bin/bash

initDNS="${name}0.${name}.${name}.oraclevcn.com"
nodeDNS=$(hostname -f)
REDIS_PORT=6379
private_ip=$(hostname -i)

# Create the list of nodes to join the cluster based on the number of instances
n=${count}
join=""

for i in $(seq 0 $(($n > 0? $n-1: 0))); do 
  nodes=$(host ${name}$i.${name}.${name}.oraclevcn.com | awk '{print $4}')
  join="$${join}$${join:+ }$nodes:$REDIS_PORT"
done

# Setup firewall rules
firewall-offline-cmd  --zone=public --add-port=6379/tcp
firewall-offline-cmd  --zone=public --add-port=16379/tcp
systemctl restart firewalld

# Install wget and gcc
yum install -y wget gcc

# Download and compile Redis
wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar xvzf redis-5.0.5.tar.gz
cd redis-5.0.5
make install

# Prepare redis.conf for clustering
cp ./redis.conf /etc/redis.conf
sed -i "s/^bind 127.0.0.1/bind $private_ip/g" /etc/redis.conf
sed -i "s/^# cluster-enabled yes/cluster-enabled yes/g" /etc/redis.conf
sed -i "s/^# cluster-config-file /cluster-config-file /g" /etc/redis.conf
sed -i "s/^# cluster-node-timeout 15000/cluster-node-timeout 15000/g" /etc/redis.conf
sed -i "s/^appendonly no/appendonly yes/g" /etc/redis.conf
sed -i "s/^daemonize no/daemonize yes/g" /etc/redis.conf
sed -i "s/^# requirepass foobared/requirepass ${password}/g" /etc/redis.conf

redis-server /etc/redis.conf
sleep 60

if [[ $initDNS == $nodeDNS ]]
then
    echo "yes" | redis-cli --cluster create $join --cluster-replicas 1 -a ${password}
fi