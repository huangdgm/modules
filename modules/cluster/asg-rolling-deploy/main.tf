terraform {
  required_version = "=0.15.3"
}

# Although it is a good practice to use input variables to allow, e.g. stage, prod, to specify their own values,
# we still need a way to define a variable in your module to do some intermediary calculation, or just to keep your code DRY,
# but you don't want to expose that variable as a configurable input.
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_launch_configuration" "example" {
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]

  # Note that the two 'template_file' data sources are both arrays, as they both use the 'count' parameter.
  # However, as one of these arrays will be of length 1 and the other of length 0, you can't directly access a specific index,
  # because that array might be empty.
//  user_data = (
//  length(data.template_file.user_data[*]) > 0
//  ? data.template_file.user_data[0].rendered
//  : data.template_file.user_data_new[0].rendered
//  )
  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  # Explicitly depend on the launch configuration's name so each time it's
  # replaced, this ASG is also replaced.
  name = "${var.cluster-name}-${aws_launch_configuration.example.name}"

  launch_configuration = aws_launch_configuration.example.name
  #vpc_zone_identifier = data.aws_subnet_ids.default.ids
  vpc_zone_identifier = var.subnet_ids

  #target_group_arns = [aws_lb_target_group.asg.arn]
  target_group_arns = var.target_group_arns
  #health_check_type = "ELB"
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # Set the 'min_elb_capacity' parameter of the ASG to the min_size of the cluster
  # so that Terraform will wait for at least that many servers from the new ASG to pass
  # health checks in the ALB before it will begin destroying the original ASG.
  min_elb_capacity = var.min_size

  # When replacing this ASG, create the replacement first, and only delete the original after.
  # The 'lifecycle' combined with the 'name' makes the zero-downtime deployment possible.
  # But, there is a limitation of zero-downtime deployment.
  # After each deployment, it resets your ASG size back to its 'min_size' regardless of how many
  # EC2 instances are running prior to the deployment. This will cause a problem because the number
  # of EC2 instances will remain unchanged until hitting the 'aws_autoscaling_schedule'.
  # However, there are two possible workarounds:
  # 1. Change the recurrence parameter on the aws_autoscaling_schedule from 0 9 * * *, which means
  # "run at 9 a.m." to something like 0-59 9-17 * * *, which means "run every minute from 9 a.m. to
  # 5 p.m." This approach is a bit of a hack, and the big jump from 10 servers to 2 servers back to
  # 10 servers can still cause issues for your users.
  # 2. Create a custom script that uses the AWS API to figure out how many servers are running in the
  # ASG, call this script using an external data source, and set the 'desired_capacity' parameter of
  # the ASG to the value returned by this script.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "${var.cluster-name}-asg-example"
    propagate_at_launch = true
  }

  # 'for_each' to loop 'custom_tags' to build multiple inline blocks within a resource
  dynamic "tag" {
    # The "{...}" below returns a map.
    for_each = {for key, value in var.custom_tags: key => upper(value) if key != "Name"}
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster-name}-instance"
}

resource "aws_security_group_rule" "allow_http_inbound_instance" {
  security_group_id = aws_security_group.instance.id
  type = "ingress"

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound_instance" {
  security_group_id = aws_security_group.instance.id
  type = "egress"

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_autoscaling_schedule" "scale_out_during_biz_hours" {
  # Allow the 'root module' to decide whether to include the current resource or not.
  count = var.enable_autoscaling ? 1 : 0

  autoscaling_group_name = aws_autoscaling_group.example.name
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 5
  desired_capacity = 3
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  autoscaling_group_name = aws_autoscaling_group.example.name
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  recurrence = "0 17 * * *"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name = "${var.cluster-name}-high-cpu-utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  # Unlike 'CPUUtilization', the CPU credits apply only to tXXX instances, e.g., t2.micro, t2.medium, etc.
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name = "${var.cluster-name}-low-cpu-credit-balance"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}