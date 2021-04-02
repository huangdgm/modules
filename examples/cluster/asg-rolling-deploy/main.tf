provider "aws" {
  region = "us-east-2"

  # Allow any 3.35.x version of the AWS provider
  version = "~> 3.35.0"
}

terraform {
  # Require Terraform at exactly version 0.14.8.
  required_version = "=0.14.8"

  # Only the 'key' parameter remains in the Terraform code, since you still need to set a different 'key' value for each module.
  # All the other repeated 'backend' arguments, such as 'bucket' and 'region', into a separate file called backend.hcl.
  backend "s3" {
    # Terraform will create the key path automatically.
    # Variables aren't allowed in a backend configuration.
    key = "modules/examples/cluster/asg-rolling-deploy/terraform.tfstate"
  }
}

module "asg" {
  source = "../../../modules/cluster/asg-rolling-deploy"

  cluster-name = "test"
  enable_autoscaling = false
  instance_type = "t2.micro"
  max_size = 2
  min_size = 1
  subnet_ids = data.aws_subnet_ids.default.ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}