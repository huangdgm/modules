terraform {
  required_version = "=1.0.2"
}

# Although it is a good practice to use input variables to allow, e.g. stage, prod, to specify their own values,
# we still need a way to define a variable in your module to do some intermediary calculation, or just to keep your code DRY,
# but you don't want to expose that variable as a configurable input.
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = [
    "0.0.0.0/0"]
}

resource "aws_lb" "example" {
  name = var.alb_name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = local.http_port
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = "404"
    }
  }
}

# Instead of putting ingress and egress rules as inline blocks, moving them out as separate resources allow you to have extra flexibility to add custom rules from outside the module.
# For example, you export the ID of the 'aws_security_group' as an output variable. And then imagine that in the staging environment, expose an extra port just for testing.
resource "aws_security_group" "alb" {
  name = var.alb_name
}

resource "aws_security_group_rule" "allow_http_inbound_alb" {
  security_group_id = aws_security_group.alb.id
  type = "ingress"

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound_alb" {
  security_group_id = aws_security_group.alb.id
  type = "egress"

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}