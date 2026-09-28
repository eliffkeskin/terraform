variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "cluster_name" {
  default = "lab-eks"
}

variable "cluster_version" {
  default = "1.33"
}

variable "admin_arn" {
  type = string
}

