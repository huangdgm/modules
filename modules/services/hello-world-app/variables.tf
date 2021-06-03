# The values of variables defined in this file are either provided in the definitions themselves(using the 'default' vaule,
# or in the 'root modules' such as the stage or prod.
# Please note that some of the variables are duplicated from other modules. This is necessary because
# the current module invoke other modules.

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "db_remote_state_bucket" {
	type = string
	description = "The name of the S3 bucket for the db's remote state"
}

variable "db_remote_state_key" {
	type = string
	description = "The path for the db's remote state in S3"
}

//variable "webserver_remote_state_bucket" {
//	type = string
//	description = "The name of the S3 bucket for the webserver's remote state"
//}
//
//variable "webserver_remote_state_key" {
//	type = string
//	description = "The path for the webserver's remote state in S3"
//}

variable "enable_new_user_data" {
	description = "If set to true, use the new user data script"
	type = bool
}

variable "server_text" {
	description = "The text the web server should return for the demonstration purpose"
	default = "Hello, world"
	type = string
}

variable "environment" {
	description = "The name of the environment we're deploying to"
	type = string
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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
	type = string
	default = "us-east-2"
}

variable "ami" {
	default = "ami-07a0844029df33d7d"
}
variable "instance_type" {
	default = "t2.micro"
}

variable "custom_tags" {
	type = map(string)
	default = {}
	description = "Custom tags to set on the instance in the ASG"
}
