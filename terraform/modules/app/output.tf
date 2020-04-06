output "load_balancer_endpoint" {
  value = kubernetes_service.flask.load_balancer_ingress[0].hostname
}
