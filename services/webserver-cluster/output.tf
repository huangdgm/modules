# The output variables defined in the 'output.tf' file are supposed to be referenced by outside of modules.
# For example, the 'asg_name' is referenced by 'aws_autoscaling_schedule' in prod.
# If you want these output values to be stored in the state files, include them in the output files under, e.g. state or prod.
output "asg_name" {
	value = aws_autoscaling_group.example.name
	description = "The name of the ASG"
}

# The 'alb_dns_name' output variable is referenced by another output variable in stage.
output "alb_dns_name" {
	value = aws_lb.example.dns_name
	description = "The domain name of the load balancer"
}