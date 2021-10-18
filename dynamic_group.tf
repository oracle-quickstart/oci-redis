resource "oci_identity_dynamic_group" "redis_dynamic_group" {

  compartment_id = var.tenancy_ocid
  description = "Dynamic group of Redis cluster Compute instances"
  matching_rule = "tag.${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}.value = '${var.release}'"
  name = "redis-cluster-dynamic-group"
}