variable "cidr" {
  description = "CIDR Block for Vpc"
  type        = string
}

variable "azs" {
  description = "Availablity Zone's"
  type        = list(string)
}
