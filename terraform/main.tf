provider "aws" {
  profile = "tm.prd"
  region  = "ap-northeast-1"
}

module "network" {
  source = "./modules/network"

  vpc_cidr_first_2_block = "10.0"

  region   = "ap-northeast-1"
  prefixes = [var.service, var.env]
  common_tags = {
    "environment" = var.env
    "service"     = var.service
  }
}

module "database" {
  source = "./modules/database"

  sg        = module.network.db_sg
  root_user = data.aws_ssm_parameter.db_root_user.value
  root_pass = data.aws_ssm_parameter.db_root_pass.value
  subnet_ids = [
    module.network.prv_subnet_id_1,
    module.network.prv_subnet_id_2,
  ]
  prefixes = [var.service, var.env]
  common_tags = {
    "environment" = var.env
    "service"     = var.service
  }
}

module "ecs" {
  source = "./modules/ecs"

  subnets = [
    module.network.prv_subnet_id_1,
    module.network.prv_subnet_id_2,
  ]
  service_sg       = module.network.service_sg
  target_group_arn = module.network.target_group_arn
  mysql_host       = module.database.host
  mysql_port       = module.database.port
  template_dir     = "./templates"
  region           = "ap-northeast-1"
  prefixes         = [var.service, var.env]
  common_tags = {
    "environment" = var.env
    "service"     = var.service
  }
}
