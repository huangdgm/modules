provider "aws" {
  region = "us-east-2"
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