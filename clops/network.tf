# Network Module
module "vpc" {
  source = "../../../modules/network"
  name   = "${var.client_name}-${var.environment}-vpc"
  cidr   = var.vpc_cidr
  azs    = local.azs

  public_subnets                     = var.public_subnets
  private_subnets                    = var.private_subnets
  # database_subnets                   = var.database_subnets
  # create_database_subnet_group       = var.create_database_subnet_group
  # create_database_subnet_route_table = var.create_database_subnet_route_table

  enable_nat_gateway                = var.enable_nat_gateway
  single_nat_gateway                = var.single_nat_gateway
  one_nat_gateway_per_az            = var.one_nat_gateway_per_az
  #create_database_nat_gateway_route = var.create_database_nat_gateway_route

  create_igw = var.create_igw

  tags = {
    Created_by = "Terraform"
    Client     = var.client_name
    Env        = var.environment
  }
}
