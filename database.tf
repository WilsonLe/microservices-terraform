# DATABASE
resource "aws_db_instance" "microservices-database" {
  allocated_storage      = 10
  identifier             = "microservices-database"
  db_name                = var.microservices-database-secrets.DB_NAME
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = "db.t3.micro"
  port                   = var.microservices-database-secrets.DB_PORT
  username               = var.microservices-database-secrets.DB_USER
  password               = var.microservices-database-secrets.DB_PASSWORD
  parameter_group_name   = "default.postgres13"
  publicly_accessible    = true
  skip_final_snapshot    = true
  apply_immediately      = true
  vpc_security_group_ids = [aws_security_group.microservices-security-group.id]
  db_subnet_group_name   = aws_db_subnet_group.microservices-subnet-group.name
}
