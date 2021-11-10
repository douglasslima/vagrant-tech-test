provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace douglas-k8s-demo
resource "kubernetes_namespace" "douglas-k8s-demo" {
  metadata {
    name = "douglas-k8s-demo"
  }
}

# mywebsite-app deployment
resource "kubernetes_deployment" "mywebsite-app-deployment" {
  metadata {
    name      = "mywebsite-app-deployment"
    namespace = kubernetes_namespace.douglas-k8s-demo.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mywebsite-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "mywebsite-app"
        }
      }
      spec {
        container {
          image = "douglasslima/my-website:1.0"
          name  = "mywebsite-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# mywebsite-app service
resource "kubernetes_service" "mywebsite-app-service" {
  metadata {
    name      = "mywebsite-app-service"
    namespace = kubernetes_namespace.douglas-k8s-demo.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.mywebsite-app-deployment.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 80
    }
  }
}

# mywebsite-app ingress
resource "kubernetes_ingress" "mywebsite-app-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "mywebsite-app-ingress"
    namespace = kubernetes_namespace.douglas-k8s-demo.metadata.0.name
    annotations = {
      "nginx.ingress.kubernetes.io/add-base-url" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = "mywebsite-app-192-168-50-11.nip.io"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.mywebsite-app-service.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}