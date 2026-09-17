variable "instance_name" {
  description = "Value of the EC2 instance's name tag"
  type        = string
}

variable "instance_type" {
  description = "The EC2's instance type"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to launch the EC2 instance in"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}
