provider "aws" {
  region = "us-east-2"

  # Allow any 3.35.x version of the AWS provider
  version = "~> 3.35.0"
}

terraform {
  required_version = "=0.15.3"

  # Only the 'key' parameter remains in the Terraform code, since you still need to set a different 'key' value for each module.
  # All the other repeated 'backend' arguments, such as 'bucket' and 'region', into a separate file called backend.hcl.
  backend "s3" {
    # Terraform will create the key path automatically.
    # Variables aren't allowed in a backend configuration.
    key = "modules/examples/services/hello-world-app/terraform.tfstate"
  }
}

module "hello_world_app" {
  // Instead of referring to source in Git, you can simply choose to refer to source in the local.
  // As opposed to referring to local source, you should always to refer to Git as source in your
  // stage, prod, etc.
  source = "../../../modules/services/hello-world-app"

  db_remote_state_bucket = "terraform3-up-and-running"
  db_remote_state_key = "modules/examples/databases/mysql/terraform.tfstate"
  enable_autoscaling = false
  enable_new_user_data = false
  environment = "example"
  max_size = 2
  min_size = 2
}