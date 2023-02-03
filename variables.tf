variable "region" {
  type = string
}
variable "microservices-database-secrets" {
  type      = map(string)
  sensitive = true
}
