## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

output "redis1_public_ip_address" {
  value = data.oci_core_vnic.redis1_vnic.public_ip_address
}

output "redis2_public_ip_address" {
  value = data.oci_core_vnic.redis2_vnic.public_ip_address
}

output "redis3_public_ip_address" {
  value = data.oci_core_vnic.redis3_vnic.public_ip_address
}

output "redis4_public_ip_address" {
  value = data.oci_core_vnic.redis4_vnic.public_ip_address
}

output "redis5_public_ip_address" {
  value = data.oci_core_vnic.redis5_vnic.public_ip_address
}

output "redis6_public_ip_address" {
  value = data.oci_core_vnic.redis6_vnic.public_ip_address
}

output "redis_password" {
  value = random_string.redis_password.result
}