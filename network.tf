## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "redis-vcn" {
  cidr_block     = var.VCN-CIDR
  compartment_id = var.compartment_ocid
  display_name   = "${var.redis-prefix}-vcn"
  dns_label      = var.redis-prefix

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

}

resource "oci_core_subnet" "redis-subnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "${var.redis-prefix}-subnet"
  dns_label         = var.redis-prefix
  security_list_ids = [oci_core_security_list.redis-securitylist.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.redis-vcn.id
  route_table_id    = oci_core_route_table.redis-rt.id
  dhcp_options_id   = oci_core_virtual_network.redis-vcn.default_dhcp_options_id

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "redis-igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.redis-prefix}-igw"
  vcn_id         = oci_core_virtual_network.redis-vcn.id

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "redis-rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.redis-vcn.id
  display_name   = "${var.redis-prefix}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.redis-igw.id
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

