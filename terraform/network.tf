resource "oci_core_virtual_network" "redis_vcn" {
  cidr_block     = "${var.VPC-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "redis_vcn"
  dns_label      = "redisvcn"
}

resource "oci_core_internet_gateway" "redis_internet_gateway" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "redis_internet_gateway"
  vcn_id         = "${oci_core_virtual_network.redis_vcn.id}"
}

resource "oci_core_route_table" "RouteForComplete" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.redis_vcn.id}"
  display_name   = "RouteTableForComplete"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.redis_internet_gateway.id}"
  }
}

resource "oci_core_route_table" "PrivateRouteTable" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.redis_vcn.id}"
  display_name   = "PrivateRouteTableForComplete"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_private_ip.bastion_private_ip.id}"

    //network_entity_id = "${lookup(data.oci_core_private_ips.myPrivateIPs.private_ips[0],"id")}"
  }
}

## Private Subnet Setup

resource "oci_core_subnet" "private" {
  count               = "3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
  cidr_block          = "${cidrsubnet(var.VPC-CIDR, 8, count.index+3)}"
  display_name        = "private_ad${count.index+1}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.redis_vcn.id}"
  route_table_id      = "${oci_core_route_table.PrivateRouteTable.id}"

  //route_table_id = "${oci_core_route_table.RouteForComplete.id}"
  security_list_ids          = ["${oci_core_security_list.PrivateSubnet.id}"]
  dhcp_options_id            = "${oci_core_virtual_network.redis_vcn.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "private${count.index+1}"
}

## Bastion Subnet Setup
resource "oci_core_subnet" "bastion" {
  count               = "3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
  cidr_block          = "${cidrsubnet(var.VPC-CIDR, 8, count.index+6)}"
  display_name        = "bastion_ad${count.index+1}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.redis_vcn.id}"
  route_table_id      = "${oci_core_route_table.RouteForComplete.id}"
  security_list_ids   = ["${oci_core_security_list.BastionSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.redis_vcn.default_dhcp_options_id}"
  dns_label           = "bastion${count.index+1}"
}

resource "oci_core_private_ip" "bastion_private_ip" {
  vnic_id      = "${lookup(data.oci_core_vnic_attachments.bastion_vnics.vnic_attachments[0],"vnic_id")}"
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
