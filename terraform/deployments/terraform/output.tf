output "app_hostname" {
  value = "http://${module.app_deployment.load_balancer_endpoint}"
}