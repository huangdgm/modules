provider "aws" {
  region = "us-east-2"

  # Allow any 3.35.x version of the AWS provider
  version = "~> 3.35.0"
}

terraform {
  required_version = "=0.14.8"

  # Only the 'key' parameter remains in the Terraform code, since you still need to set a different 'key' value for each module.
  # All the other repeated 'backend' arguments, such as 'bucket' and 'region', into a separate file called backend.hcl.
  backend "s3" {
    # Terraform will create the key path automatically.
    # Variables aren't allowed in a backend configuration.
    key = "modules/examples/databases/mysql/terraform.tfstate"
  }
}

module "mysql_db" {
  source = "../../../modules/databases/mysql"

  allocated_storage = 5
  db_name = "example_database"
  instance_class = "db.t2.micro"
}
