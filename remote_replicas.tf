data "template_file" "redis_bootstrap_replica_template" {
  template = file("./scripts/redis_bootstrap_replica.sh")

  vars = {
    redis_version      = var.redis_version
    redis_port1        = var.redis_port1
    redis_port2        = var.redis_port2
    sentinel_port      = var.sentinel_port
    redis_password     = random_string.redis_password.result
  }
}

resource "null_resource" "redis4_bootstrap" {
  depends_on = [oci_core_instance.redis1, oci_core_instance.redis2, oci_core_instance.redis3, oci_core_instance.redis4, oci_core_instance.redis5, oci_core_instance.redis6]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis4_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = data.template_file.redis_bootstrap_replica_template.rendered
    destination = "~/redis_bootstrap_replica.sh"
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
      "chmod +x ~/redis_bootstrap_replica.sh",
      "sudo ~/redis_bootstrap_replica.sh",
    ]
  }
}

resource "null_resource" "redis5_bootstrap" {
  depends_on = [oci_core_instance.redis1, oci_core_instance.redis2, oci_core_instance.redis3, oci_core_instance.redis4, oci_core_instance.redis5, oci_core_instance.redis6]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis5_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = data.template_file.redis_bootstrap_replica_template.rendered
    destination = "~/redis_bootstrap_replica.sh"
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
      "chmod +x ~/redis_bootstrap_replica.sh",
      "sudo ~/redis_bootstrap_replica.sh",
    ]
  }
}

resource "null_resource" "redis6_bootstrap" {
  depends_on = [oci_core_instance.redis1, oci_core_instance.redis2, oci_core_instance.redis3, oci_core_instance.redis4, oci_core_instance.redis5, oci_core_instance.redis6]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis6_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = data.template_file.redis_bootstrap_replica_template.rendered
    destination = "~/redis_bootstrap_replica.sh"
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
      "chmod +x ~/redis_bootstrap_replica.sh",
      "sudo ~/redis_bootstrap_replica.sh",
    ]
  }
}

