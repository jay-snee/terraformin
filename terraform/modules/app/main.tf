resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "flask-env" {
  metadata {
    name = "${var.release_name}-env"
    namespace = var.namespace
  }

  data = {
    USERNAME     = var.http_username
    PASSWORD     = var.http_password
    THEBIGSECRET = var.app_secret
    REDIS_HOST   = var.redis_host
    REDIS_PORT   = var.redis_port
  }
}

resource "kubernetes_deployment" "flask-deployment" {
  metadata {
    name      = var.release_name
    namespace = var.namespace
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "${var.release_name}-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.release_name}-app"
        }
      }

      spec {
        container {
          image = "jaysnee/terraform-test:0.3"
          name  = "flask"

          env_from {
            secret_ref {
              name = "${var.release_name}-env"
            }
          }
          
          port {
            container_port = 5000
          }
          
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "${var.release_name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "${var.release_name}-app"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}