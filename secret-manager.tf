# SECRET MANAGER
resource "aws_secretsmanager_secret" "microservices-database-secrets" {
  name        = "microservices-database-secrets"
  description = "access to microservices database secrets"
}

resource "aws_secretsmanager_secret_version" "microservices-database-secrets" {
  secret_id = aws_secretsmanager_secret.microservices-database-secrets.id
  secret_string = jsonencode({
    DATABASE_HOST     = "${aws_db_instance.microservices-database.address}"
    DATABASE_PORT     = "${var.microservices-database-secrets.DB_PORT}"
    DATABASE_NAME     = "${var.microservices-database-secrets.DB_NAME}"
    DATABASE_USERNAME = "${var.microservices-database-secrets.DB_USER}"
    DATABASE_PASSWORD = "${var.microservices-database-secrets.DB_PASSWORD}" }
  )
}
