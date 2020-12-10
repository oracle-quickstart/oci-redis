
resource "oci_core_instance" "redis1" {
  availability_domain = var.availablity_domain_name
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_ocid
  display_name        = "${var.redis-prefix}1"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.redis-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.redis-prefix}1"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

resource "oci_core_instance" "redis2" {
  availability_domain = var.availablity_domain_name
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_ocid
  display_name        = "${var.redis-prefix}2"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.redis-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.redis-prefix}2"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

resource "oci_core_instance" "redis3" {
  availability_domain = var.availablity_domain_name
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_ocid
  display_name        = "${var.redis-prefix}3"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.redis-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.redis-prefix}3"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

