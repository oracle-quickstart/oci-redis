output "1 - Bastion SSH Login" {
  value = <<END

	ssh -i ~/.ssh/id_rsa opc@${data.oci_core_vnic.bastion_vnic.public_ip_address}

END
}

output "2 - Redis Node-1(redis-node-1) SSH Login" {
  value = <<END

First ssh to the bastion host using above command and then ssh to redis-node-1, since its on a private subnet and only accessible via bastion host.

	ssh -i /home/opc/.ssh/id_rsa opc@redis-node-1

END
}

output "3 - On Redis Node-1 run the command from the below file" {
  value = <<END

Run this to create the cluster and when prompted reply with yes. First ssh to redis-node-1 using the ssh information provided above.

	cat /home/opc/redis_cluster_create_cmd.sh

END
}
