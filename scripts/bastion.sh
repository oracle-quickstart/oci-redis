#!/bin/bash
#### Bastion Master Setup Script
set -x

ssh_check () {
	ssh_chk="1"
	failsafe="1"
	if [ -z $user ]; then
		user="opc"
	fi
	echo -ne "Checking SSH as $user on ${hostfqdn} [*"
        while [ "$ssh_chk" != "0" ]; do
		ssh_chk=`ssh -o StrictHostKeyChecking=no -q -i /home/opc/.ssh/id_rsa ${user}@${hostfqdn} 'echo 0'`
                if [ -z $ssh_chk ]; then
                        sleep 5
                        echo -n "*"
                        continue
                elif [ $ssh_chk = "0" ]; then
                        if [ $failsafe = "1" ]; then
                                failsafe="0"
                                ssh_check="1"
                                sleep 10
                                echo -n "*"
                                continue
                        else
                                continue
                        fi
                else
                        sleep 5
                        echo -n "*"
                        continue
                fi
        done;
	echo -ne "*] - DONE\n"
        unset sshchk
	unset user
}

host_discovery () {
## MASTER NODE DISCOVERY
# endcheck=1
# while [ "$endcheck" = "1" ]; do
#         for i in `seq 1 7`; do
#                 hname=`host redis-node-${i}`
#                 hchk=$?
#                 if [ "$hchk" -eq "1" ]; then
#                         endcheck="0"
#                 else
#                         echo "$hname" | head -n 1 | gawk '{print $1}'
#                         endcheck="1"
#                 fi
#         done;
# done;

## REDIS NODE DISCOVERY
endcheck=1
i=1
while [ "$endcheck" != 0 ]; do
        hname=`host redis-node-${i}`
        hchk=$?
        if [ "$hchk" -eq "1" ]; then
                endcheck="0"
        else
                echo "$hname" | head -n 1 | gawk '{print $1}'
                endcheck="1"
        fi
        i=$((i+1))
done;
}

### Main execution below this point - all tasks are initiated from Bastion host inside screen session called from remote-exec ##
cd /home/opc/

## Set DNS to resolve all subnet domains
sudo rm -f /etc/resolv.conf
sudo echo "search private1.redisvcn.oraclevcn.com private2.redisvcn.oraclevcn.com private3.redisvcn.oraclevcn.com bastion1.redisvcn.oraclevcn.com bastion2.redisvcn.oraclevcn.com bastion3.redisvcn.oraclevcn.com" > /etc/resolv.conf
sudo echo "nameserver 169.254.169.254" >> /etc/resolv.conf

## Cleanup any exiting files just in case
if [ -f host_list ]; then
	rm -f host_list;
	#rm -f redisnodes;
	rm -f hosts_ip;
	rm -f hosts;
fi

## Continue with Main Setup
# First do some network & host discovery
host_discovery >> host_list
#cat host_list | grep slave >> slavenodes
#cat host_list | grep master >> masternodes
master1fqdn=`cat host_list | grep redis-node-1`
#w1fqdn=`cat host_list | grep cdh-worker-1`
for host in `cat host_list`; do
	h_ip=`dig +short $host`
	echo -e "$h_ip\t$host" >> hosts
	echo -e "$h_ip" >> hosts_ip
done;

## REFACTOR THE NETWORK LOOKUP FOR MULTI AD SUPPORT - OR JUST WHITELIST KNOWN SUBNET 10.0.0.0/16 - Only needed for Firewall Enabled
#unset local_network
# if [ -f hosts ]; then
# 	local_network="10.0.0.0/16"
# 	#local_network=`cat hosts | grep -w "cdh-worker-1" | gawk '{print $1}' | cut -d '.' -f 1-3`
# fi
master1_ip=`dig +short ${master1fqdn}`
#sed -i "s/MASTERIP/$master_ip/g" redis_deploy_slave.sh

## Primary host setup section
for host in `cat host_list | gawk -F '.' '{print $1}'`; do
	hostfqdn=`cat host_list | grep $host`
        echo -e "\tConfiguring $host for deployment."
        host_ip=`cat hosts | grep $host | gawk '{print $1}'`
        ssh_check
	echo -e "Copying Setup Scripts...\n"
        ## Copy Setup scripts
        ##scp -o BatchMode=yes -o StrictHostkeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/hosts opc@$hostfqdn:~/
				##scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/.ssh/id_rsa opc@$hostfqdn:~/.ssh/
				##scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/host_list opc@$hostfqdn:~/
				##scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/hosts_ip opc@$hostfqdn:~/
				##ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn "chmod 0600 .ssh/id_rsa"
        ##scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/redis_deploy.sh opc@$hostfqdn:~/
        #scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/redis_deploy_slave.sh opc@$hostfqdn:~/
        # scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/tune.sh opc@$hostfqdn:~/
        # scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/disk_setup.sh opc@$hostfqdn:~/
        ## Set Execute Flag on scripts
        ##ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn 'chmod +x *.sh'
        ## Execute Node Prep
        # ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn 'sudo ./node_prep.sh &'

				# cat host_list | grep -q -w $host
				# if [ $? -eq 0 ]; then
        echo -e "\tRunning Redis Nodes Setup for Cluster..."
				# ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn 'sudo ./redis_deploy.sh'
				# fi

				# cat slavenodes | grep -q -w $host
				# if [ $? -eq 0 ]; then
        #         echo -e "\tRunning Slave Setup..."
				# 				ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn 'sudo ./redis_deploy_slave.sh'
				# fi

        echo -e "\tDone initializing $host.\n\n"
done;

node_ip_list=""
for host_ip in `cat /home/opc/hosts_ip`; do
        node_ip_list+="$host_ip:6379 ";
done;
echo $node_ip_list



for host in `cat host_list | gawk -F '.' '{print $1}'`; do
	hostfqdn=`cat host_list | grep $host`
	loop=1
	while [ $loop -eq 1 ]; do
		ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$hostfqdn 'cat /home/opc/complete'
		if [ $? -eq 0 ]; then
			loop="0"
		else
			echo "check again after 10s"
			sleep 10s;
			loop="1"
		fi
	done;
done;

redis_cluster_create_cmd="redis-cli --cluster create ";
redis_cluster_create_cmd+="$node_ip_list  --cluster-replicas 1"

echo $redis_cluster_create_cmd > redis_cluster_create_cmd.txt


scp -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa /home/opc/redis_cluster_create_cmd.txt opc@$master1fqdn:~/
## RUN the COMMAND mentioned in the file (/home/opc/redis_cluster_create_cmd.txt) manually on one of the redis-node-x instance. It requires user to confirm the command execution.


set +x
