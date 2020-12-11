resource "null_resource" "redis_cluster_startup" {
  depends_on = [null_resource.redis1_bootstrap, null_resource.redis2_bootstrap, null_resource.redis3_bootstrap, null_resource.redis4_bootstrap, null_resource.redis5_bootstrap, null_resource.redis6_bootstrap]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis1_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis1 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis1 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis2_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis2 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis1 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis3_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis3 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis3 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis4_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis4 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo -u root cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis4 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis5_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis5 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo -u root cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis5 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis6_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis6 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo -u root cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis6 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis1_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Create REDIS CLUSTER from redis1 node... ==='",
      "sudo -u root /usr/local/bin/redis-cli --cluster create ${data.oci_core_vnic.redis1_vnic.private_ip_address}:6379 ${data.oci_core_vnic.redis2_vnic.private_ip_address}:6379 ${data.oci_core_vnic.redis3_vnic.private_ip_address}:6379 ${data.oci_core_vnic.redis4_vnic.private_ip_address}:6379 ${data.oci_core_vnic.redis5_vnic.private_ip_address}:6379 ${data.oci_core_vnic.redis6_vnic.private_ip_address}:6379 -a ${random_string.redis_password.result} --cluster-replicas 1 --cluster-yes",
      "echo '=== Cluster REDIS created from redis1 node... ==='",
      "echo 'cluster info' | /usr/local/bin/redis-cli -c -a ${random_string.redis_password.result}",
      "echo 'cluster nodes' | /usr/local/bin/redis-cli -c -a ${random_string.redis_password.result}"
    ]
  }
}

