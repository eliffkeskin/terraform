module "network" {
  source = "../vpc-alb/modules/network"
  cidr   = var.vpc_cidr
  azs    = var.azs
}
