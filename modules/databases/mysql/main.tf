terraform {
  required_version = "=1.0.2"
}

//
//data "aws_secretsmanager_secret_version" "db_password" {
//  secret_id = "mysql-master-password-stage"
//}

resource "aws_db_instance" "example" {
  engine = "mysql"

  instance_class    = var.instance_class
  identifier_prefix = var.identifier_prefix
  allocated_storage = var.allocated_storage
  name              = var.db_name
  skip_final_snapshot = true

  username = "admin"

  # Use a Terraform data source to read the secrets from a secret store
  # password = data.aws_secretsmanager_secret_version.db_password.secret_string
  password = "administrator"
}