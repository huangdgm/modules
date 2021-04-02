provider "aws" {
  region = "us-east-2"
}

module "mysql_db" {
  source = "../../../modules/databases/mysql"

  allocated_storage = 5
  db_name = "example_database"
  instance_class = "db.t2.micro"
}
