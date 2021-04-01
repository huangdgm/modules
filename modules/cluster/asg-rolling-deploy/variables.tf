variable "cluster-name" {
  type = string
  description = "The name to use for all the cluster resources"
}

variable "ami" {
  description = "The AMI to run in the cluster"
  default = "ami-07a0844029df33d7d"
  type = string
}

variable "instance_type" {
  type = string
  description = "The type of EC2 instances to run (e.g. t2.micro)"
}

variable "min_size" {
  type = number
  description = "The minimum number of EC2 instances in the ASG"
}

variable "max_size" {
  type = number
  description = "The maximum number of EC2 instances in the ASG"
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "custom_tags" {
  type = map(string)
  default = {}
  description = "Custom tags to set on the instance in the ASG"
}

# By exposing the 'subnet_ids' variable, you allow this module to be used with any VPC or subnets.
variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type = list(string)
  default = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type = string
  default = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each Instance at boot"
  type = string
  default = "sudo yum update -y"
}