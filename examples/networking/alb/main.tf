provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Allow any 3.33.x version of the AWS provider
      version = "~> 3.33.0"
    }
  }

  required_version = "=1.0.2"

  # Only the 'key' parameter remains in the Terraform code, since you still need to set a different 'key' value for each module.
  # All the other repeated 'backend' arguments, such as 'bucket' and 'region', into a separate file called backend.hcl.
  backend "s3" {
    # Terraform will create the key path automatically.
    # Variables aren't allowed in a backend configuration.
    key = "modules/examples/networking/alb/terraform.tfstate"
  }
}

data aws_vpc "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "my-alb" {
  source = "../../../modules/networking/alb"

  alb_name = "my-alb"
  subnet_ids = data.aws_subnet_ids.default.ids
}
