output "asg_name" {
  value = aws_autoscaling_group.example.name
  description = "The name of the Auto Scaling Group"
}

# Outputting this data makes the 'asg-rolling-deploy' module even more reusable, since
# consumers of the module can use these outputs to add new behaviors, such as attaching
# custom rules to the security group.
output "instance_security_group_id" {
  value = aws_security_group.instance.id
  description = "The ID of the EC2 Instance Security Group"
}