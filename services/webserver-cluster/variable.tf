variable "region" {
	type = string
	default = "us-east-2"
}

variable "cluster-name" {
	type = string
	description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
	type = string
	description = "The name of the S3 bucket for the db's remote state"
}

variable "db_remote_state_key" {
	type = string
	description = "The path for the db's remote state in S3"
}

variable "webserver_remote_state_bucket" {
	type = string
	description = "The name of the S3 bucket for the webserver's remote state"
}

variable "webserver_remote_state_key" {
	type = string
	description = "The path for the webserver's remote state in S3"
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