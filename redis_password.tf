resource "random_string" "redis_password" {
  length  = 64
  special = false
}
