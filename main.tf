variable "VPC-CIDR" {
  default = "10.0.0.0/16"
}

resource "oci_core_virtual_network" "redis_vcn" {
  cidr_block = "${var.VPC-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "redis_vcn"
  dns_label = "redisvcn"
}

resource "oci_core_internet_gateway" "redis_internet_gateway" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "redis_internet_gateway"
    vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
}

resource "oci_core_route_table" "RouteForComplete" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
    display_name = "RouteTableForComplete"
    route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.redis_internet_gateway.id}"
    }
}

resource "oci_core_route_table" "PrivateRouteTable" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
    display_name = "PrivateRouteTableForComplete"
    route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_private_ip.bastion_private_ip.id}"
        //network_entity_id = "${lookup(data.oci_core_private_ips.myPrivateIPs.private_ips[0],"id")}"
    }
}


resource "oci_core_security_list" "PrivateSubnet" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Private"
    vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "all"
    }]
    egress_security_rules = [{
	protocol = "all"
	destination = "${var.VPC-CIDR}"
    }]
    ingress_security_rules = [{
        protocol = "6"
        source = "${var.VPC-CIDR}"
    }]
    ingress_security_rules = [{
        tcp_options {
            "max" = 22
            "min" = 22
        }
        protocol = "6"
        source = "${var.VPC-CIDR}"
    },
    {
        tcp_options {
            "max" = 6379
            "min" = 6379
        }
        protocol = "6"
        source = "${var.VPC-CIDR}"
    },
    {
        tcp_options {
            "max" = 16379
            "min" = 16379
        }
        protocol = "6"
        source = "${var.VPC-CIDR}"
    }
    ]
}

resource "oci_core_security_list" "BastionSubnet" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Bastion"
    vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
    egress_security_rules = [{
    	protocol = "6"
            destination = "0.0.0.0/0"
    }]
    ingress_security_rules = [{
        tcp_options {
            "max" = 22
            "min" = 22
        }
        protocol = "6"
        source = "0.0.0.0/0"
    },
  	{
  	    protocol = "6"
        source = "${var.VPC-CIDR}"
    }]
}

## Publicly Accessable Subnet Setup
/*
resource "oci_core_subnet" "public" {
  count = "3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
  cidr_block = "${cidrsubnet(var.VPC-CIDR, 8, count.index)}"
  display_name = "public_ad${count.index+1}"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
  route_table_id = "${oci_core_route_table.RouteForComplete.id}"
  security_list_ids = ["${oci_core_security_list.PublicSubnet.id}"]
  dhcp_options_id = "${oci_core_virtual_network.redis_vcn.default_dhcp_options_id}"
  dns_label = "public${count.index+1}"
}
*/

## Private Subnet Setup

resource "oci_core_subnet" "private" {
  count = "3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
  cidr_block = "${cidrsubnet(var.VPC-CIDR, 8, count.index+3)}"
  display_name = "private_ad${count.index+1}"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
  route_table_id = "${oci_core_route_table.PrivateRouteTable.id}"
  //route_table_id = "${oci_core_route_table.RouteForComplete.id}"
  security_list_ids = ["${oci_core_security_list.PrivateSubnet.id}"]
  dhcp_options_id = "${oci_core_virtual_network.redis_vcn.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"
  dns_label = "private${count.index+1}"
}

## Bastion Subnet Setup
resource "oci_core_subnet" "bastion" {
  count = "3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
  cidr_block = "${cidrsubnet(var.VPC-CIDR, 8, count.index+6)}"
  display_name = "bastion_ad${count.index+1}"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.redis_vcn.id}"
  route_table_id = "${oci_core_route_table.RouteForComplete.id}"
  security_list_ids = ["${oci_core_security_list.BastionSubnet.id}"]
  dhcp_options_id = "${oci_core_virtual_network.redis_vcn.default_dhcp_options_id}"
  dns_label = "bastion${count.index+1}"
}


// provider.tf
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}


// variables.tf
###
## Variables here are sourced from env, but still need to be initialized for Terraform
###

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" { default = "us-phoenix-1" }

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "ssh_private_key_path" {}

//variable "AD" { default = "2" }

variable "InstanceImageOCID" {
    type = "map"
    default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaasez4lk2lucxcm52nslj5nhkvbvjtfies4yopwoy4b3vysg5iwjra"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa2tq67tvbeavcmioghquci6p3pvqwbneq3vfy7fe7m7geiga4cnxa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaakzrywmh7kwt7ugj5xqi5r4a7xoxsrxtc7nlsdyhmhqyp7ntobjwq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaalsdgd47nl5tgb55sihdpqmqu2sbvvccjs6tmbkr4nx2pq5gkn63a"
  }
}

variable "bastion_node_count" { default = "1" }
variable "bastion_instance_shape" {
  default = "VM.Standard2.2"
}

variable "redis_node_count" { default = "6" }
variable "redis_instance_shape" {
  default = "VM.Standard2.2"
}

/*
variable "slave_node_count" { default = "0" }
variable "slave_instance_shape" {
  default = "VM.Standard2.2"
}
*/

// datasources.tf
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get list of VNICS for bastion node
data "oci_core_vnic_attachments" "bastion_vnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  instance_id = "${oci_core_instance.bastion.*.id[0]}"
}


resource "oci_core_private_ip" "bastion_private_ip" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics.vnic_attachments[0],"vnic_id")}"
  display_name = "bastion_private_ip"
}

/*
data "oci_core_private_ips" "myPrivateIPs" {
    ip_address = "${data.oci_core_vnic.bastion_vnic.private_ip_address}"
    subnet_id = "${oci_core_subnet.bastion.*.id[0]}" // "${oci_core_subnet.MgmtSubnet.id}"
    #vnic_id =  "${data.oci_core_vnic.NatInstanceVnic.id}"
}
*/

# Get VNIC ID for first VNIC on bastion
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics.vnic_attachments[0],"vnic_id")}"
}


// compute.tf
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
    source_id = "${var.InstanceImageOCID[var.region]}"
    //boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  create_vnic_details {
    subnet_id = "${oci_core_subnet.bastion.*.id[count.index%3]}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file("scripts/bastion_boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}

// master node
resource "oci_core_instance" "redis_node" {
  count		      = "${var.redis_node_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index%2],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "redis node ${format("%01d", count.index+1)}"
  hostname_label      = "redis-node-${format("%01d", count.index+1)}"
  shape               = "${var.redis_instance_shape}"
  subnet_id           = "${oci_core_subnet.private.*.id[count.index%2]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    //boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file("./scripts/redis_deploy.sh"))}"
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
    //user_data = "${base64encode(file("../scripts/boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}
*/


// remote-exec.tf
resource "null_resource" "redis-deploy" {
    depends_on = ["oci_core_instance.redis_node","oci_core_instance.bastion"]
    provisioner "file" {
      source = "./scripts/"
      destination = "/home/opc/"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
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
      source = "/home/opc/.ssh/id_rsa"
      destination = "/home/opc/.ssh/id_rsa"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
      }
      inline = [
	"chown opc:opc /home/opc/.ssh/id_rsa",
	"chmod 0600 /home/opc/.ssh/id_rsa",
	"chmod +x /home/opc/*.sh",
	"/home/opc/start.sh",
	"echo SCREEN SESSION RUNNING ON BASTION AS ROOT"
	]
    }
}


output "1 - Bastion SSH Login" {
  value = <<END

	ssh -i ~/.ssh/id_rsa opc@${data.oci_core_vnic.bastion_vnic.public_ip_address}

END
}

output "2 - Bastion Commands after SSH login to watch installation process" {
  value = <<END

	sudo su -
	screen -r

END
}


output "3 - Redis Node-1(redis-node-1) SSH Login" {
  value = <<END

First ssh to the bastion host using above command and then ssh to redis-node-1, since its on a private subnet and only accessible via bastion host.

	ssh -i ~/.ssh/id_rsa opc@$redis-node-1

END
}

output "4 - On Redis Node-1 run the command from the below file" {
  value = <<END

Run this to create the cluster and when prompted reply with yes. First ssh to redis-node-1 using the ssh information provided above.

	less /home/opc/redis_cluster_create_cmd.txt

END
}
