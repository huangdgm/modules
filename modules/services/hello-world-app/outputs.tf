# The output variables defined in the 'outputs.tf' file are supposed to be referenced by outside of modules.
# For example, the 'asg_name' is referenced by 'aws_autoscaling_schedule' in prod.
# If you want these output values to be stored in the state files, include them in the output files under, e.g. state or prod.
output "asg_name" {
	value = module.asg.asg_name
	description = "The name of the ASG"
}

# The 'alb_dns_name' output variable is referenced by another output variable in stage.
output "alb_dns_name" {
	value = module.alb.alb_dns_name
	description = "The domain name of the load balancer"
	sensitive = true	# As a demo here, you can
}

output "instance_security_group_id" {
	value = module.asg.instance_security_group_id
	description = "The ID of the EC2 instance Security Group"
}