output "Redis-IP" {
  value = data.oci_core_vnic.redis_vnic.public_ip_address
}

output "Redis-Password" {
  value     = random_string.redis_password.result
  sensitive = false
}

