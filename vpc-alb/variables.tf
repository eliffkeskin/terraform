
variable "instance_name" {
  description = "Value of the EC2 instance's name tag"
  type        = string
  default     = "web"
}

variable "instance_type" {
  description = "The EC2's instance type"
  type        = string
  default     = "t3.micro"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["eu-central-1a", "eu-central-1b"]
}