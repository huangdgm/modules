terraform {
  required_version = "=1.0.2"
}

# Under the hood, the information provided by data source is fetched by calling AWS API.
data "aws_vpc" "default" {
  # Direct Terraform to lookup the default VPC in your AWS account
  default = true
}

# The [CONFIG] list serves as the filter.
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# You can use this data source to fetch the Terraform state file stored by another set of Terraform configurations in a completely read-only manner.
# The way to fetch the data from terraform_remote_state is through 'outputs'.
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = var.region
  }
}

# Externalize the user data file.
data "template_file" "user_data" {
  // Limitations of 'count' and 'for_each':
  // 1. Terraform requires that it can compute 'count' and 'for_each' during the plan phase, before any
  // resources are created or modified. This means that count and for_each can reference hardcoded values,
  // variables, data sources, and even list of resources (so long as the length of the list can be
  // determined during plan), but not computed resource outputs.
  // For example, count cannot reference an random integer data source as the value of this random integer
  // cannot be determined during the plan phase.
  // 2. You cannot use count or for_each within a module configuration. Note this feature might be supported
  // in a future terraform release. Refer to changelog in the following url:
  // https://github.com/hashicorp/terraform/blob/v0.14/CHANGELOG.md
  count = var.enable_new_user_data ? 0 : 1

  template = file("${path.module}/user-data.sh")

  // Another way to define variables.
  // These variables are dedicated for the usage by 'user-data.sh'.
  vars = {
    // Note the first time you run 'terraform apply' will give you an error on 'alb_dns_name',
    // because the state of webserver-cluster has no info regarding 'alb_dns_name.
    // This is unlike 'db_address' or 'db_port' which were created before.
    // alb_dns_name = data.terraform_remote_state.webserver-cluster.outputs.alb_dns_name
    alb_dns_name = local.http_port
    alb_listener_port = local.http_port
    // To reference another variable prefixed with 'var'.
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }
}

data "template_file" "user_data_new" {
  count = var.enable_new_user_data ? 1 : 0

  template = file("${path.module}/user-data-new.sh")

  // Another way to define variables.
  // These variables are dedicated for the usage by 'user-data.sh'.
  vars = {
    // Note the first time you run 'terraform apply' will give you an error on 'alb_dns_name',
    // because the state of webserver-cluster has no info regarding 'alb_dns_name.
    // This is unlike 'db_address' or 'db_port' which were created before.
    // alb_dns_name = data.terraform_remote_state.webserver-cluster.outputs.alb_dns_name
    alb_dns_name = local.http_port
    alb_listener_port = local.http_port
    // To reference another variable prefixed with 'var'.
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }
}

locals {
  http_port = 80
}

resource "aws_lb_target_group" "asg" {
  name = "hello-world-${var.environment}"
  port = local.http_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }

  condition {
    path_pattern {
      values = [
        "*"]
    }
  }
}

module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster-name = "hello-world-${var.environment}"
  ami = var.ami
  user_data = data.template_file.user_data[0].rendered
  instance_type = var.instance_type

  min_size = var.min_size
  max_size = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name = "hello-world-${var.environment}"
  subnet_ids = data.aws_subnet_ids.default.ids
}