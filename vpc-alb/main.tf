module "network" {
  source = "./modules/network"

  azs  = var.azs
  cidr = var.cidr



}

module "web" {
  source = "./modules/web"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  instance_name = var.instance_name
  instance_type = var.instance_type

  depends_on = [module.network]

}
