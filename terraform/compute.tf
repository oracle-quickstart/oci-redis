resource "oci_core_instance" "bastion" {
  count               = "${var.bastion_node_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index%3],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "redis bastion ${format("%01d", count.index+1)}"
  hostname_label      = "redis-bastion-${format("%01d", count.index+1)}"
  shape               = "${var.bastion_instance_shape}"
  subnet_id           = "${oci_core_subnet.bastion.*.id[count.index%3]}"

  source_details {
    source_type = "image"
    source_id   = "${var.InstanceImageOCID[var.region]}"

    //boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.bastion.*.id[count.index%3]}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file("../scripts/bastion_boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}

// master node
resource "oci_core_instance" "redis_node" {
  count               = "${var.redis_node_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index%2],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "redis node ${format("%01d", count.index+1)}"
  hostname_label      = "redis-node-${format("%01d", count.index+1)}"
  shape               = "${var.redis_instance_shape}"
  subnet_id           = "${oci_core_subnet.private.*.id[count.index%2]}"

  source_details {
    source_type = "image"
    source_id   = "${var.InstanceImageOCID[var.region]}"

    //boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file("../scripts/redis_deploy.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}

// slave node
/*
resource "oci_core_instance" "slave_node" {
  count		      = "${var.slave_node_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[(count.index+1)%2],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "redis slave ${format("%01d", count.index+1)}"
  hostname_label      = "redis-slave-${format("%01d", count.index+1)}"
  shape               = "${var.slave_instance_shape}"
  subnet_id           = "${oci_core_subnet.private.*.id[(count.index+1)%2]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    //boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    //user_data = "${base64encode(file(".../scripts/boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}
*/

// remote-exec.tf
resource "null_resource" "redis-deploy" {
  depends_on = ["oci_core_instance.redis_node", "oci_core_instance.bastion"]

  provisioner "file" {
    source      = "../scripts/"
    destination = "/home/opc/"

    connection {
      agent       = false
      timeout     = "10m"
      host        = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }
  }

  /*
                provisioner "file" {
                  source = "scripts/bastion.sh"
                  destination = "/home/opc/bastion.sh"
                  connection {
                    agent = false
                    timeout = "10m"
                    host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
                    user = "opc"
                    private_key = "${var.ssh_private_key}"
                }
                }
                */
  provisioner "file" {
    source      = "${var.ssh_private_key_path}"
    destination = "/home/opc/.ssh/id_rsa"

    connection {
      agent       = false
      timeout     = "10m"
      host        = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "chown opc:opc /home/opc/.ssh/id_rsa",
      "chmod 0600 /home/opc/.ssh/id_rsa",
      "chmod +x /home/opc/*.sh",
      "/home/opc/start.sh",
      "echo SCREEN SESSION RUNNING ON BASTION AS ROOT",
    ]
  }
}
