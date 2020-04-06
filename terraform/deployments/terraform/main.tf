module "redis" {
  source                     = "../../modules/services/redis"
  cluster_name               = var.cluster_name
  region                     = var.region
  release_name               = var.release_name
  services_subnet_cidr_block = var.services_subnet_cidr_block
}

module "app_deployment" {
  source        = "../../modules/app"
  region        = var.region
  namespace     = var.namespace
  redis_host    = module.redis.redis_host
  redis_port    = module.redis.redis_port
  http_password = var.http_password
  http_username = var.http_username
  app_secret    = var.app_secret
}