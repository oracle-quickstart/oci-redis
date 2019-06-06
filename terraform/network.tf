resource "oci_core_virtual_network" "VCN" {
  cidr_block     = "${var.CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.instance["name"]}VCN"
  dns_label      = "${lower(var.instance["name"])}"
}

resource "oci_core_subnet" "Subnet" {
  cidr_block = "10.0.1.0/24"

  display_name      = "${var.instance["name"]}"
  dns_label         = "${var.instance["name"]}"
  security_list_ids = ["${oci_core_security_list.SecurityList.id}"]
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.VCN.id}"
  route_table_id    = "${oci_core_route_table.RT.id}"
  dhcp_options_id   = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}

resource "oci_core_internet_gateway" "IG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.instance["name"]}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
}

resource "oci_core_route_table" "RT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "${var.instance["name"]}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.IG.id}"
  }
}
