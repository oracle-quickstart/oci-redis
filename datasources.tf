## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_core_vnic_attachments" "redis1_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis1.id
}

data "oci_core_vnic" "redis1_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis1_vnics.vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "redis2_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis2.id
}

data "oci_core_vnic" "redis2_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis2_vnics.vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "redis3_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis3.id
}

data "oci_core_vnic" "redis3_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis3_vnics.vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "redis4_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis4.id
}

data "oci_core_vnic" "redis4_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis4_vnics.vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "redis5_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis5.id
}

data "oci_core_vnic" "redis5_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis5_vnics.vnic_attachments.0.vnic_id
}

data "oci_core_vnic_attachments" "redis6_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.redis6.id
}

data "oci_core_vnic" "redis6_vnic" {
  vnic_id = data.oci_core_vnic_attachments.redis6_vnics.vnic_attachments.0.vnic_id
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
    tenancy_id = var.tenancy_ocid

    filter {
      name   = "is_home_region"
      values = [true]
    }
}

