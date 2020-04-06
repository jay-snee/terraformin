module "redis" {
  source                     = "../../modules/services/redis"
  cluster_name               = var.cluster_name
  region                     = var.region
  release_name               = var.release_name
  services_subnet_cidr_block = var.services_subnet_cidr_block
}

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "package" {
  name       = var.release_name
  chart      = "../../../chart"
  namespace  = var.namespace
  version    = var.chart_version

  values = [
    <<EOF
    redis:
      port: "${module.redis.redis_port}"
      host: "${module.redis.redis_host}"
    http_auth:
      password: "${var.http_password}"
      username: "${var.http_username}"
    app:
      secret: "${var.app_secret}"
    EOF
  ]
}