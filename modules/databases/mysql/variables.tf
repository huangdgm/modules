variable "instance_class" {
  type = string
  description = "The instance type of the mysql db instance"
}

variable "identifier_prefix" {
  type = string
  default = "terraform-up-and-running"
}

variable "allocated_storage" {
  type = number
  description = "The storage size in GB to allocate to the mysql db instance"
}

variable "db_name" {
  type = string
  description = "The name of the mysql db instance"
}