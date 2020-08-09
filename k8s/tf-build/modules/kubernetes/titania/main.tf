terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.12.0"
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    labels = {
      app = "titania"
    }
    name = var.namespace
  }
}

resource "kubernetes_daemonset" "titania-boot" {
  metadata {
    name      = "titania"
    namespace = var.namespace
    labels = {
      app = "titania"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "titania"
      }
    }

    template {
      metadata {
        labels = {
          app = "titania"
        }
      }

      spec {
        dns_policy = "ClusterFirstWithHostNet"
        host_network = true
        
        container {
          image = "sgryczan/titania:"${var.image_tag}""
          name  = "titania-boot"
          args = [
            "api"
            "-d"
            "--dhcp-no-bind"
            "--ipxe-ipxe"
            "/ipxe/src/bin/undionly.kpxe"
            "--ipxe-efi64"
            "/ipxe/src/bin/undionly.kpxe"
            "--ipxe-bios"
            "/ipxe/src/bin/undionly.kpxe"
            "http://titania-api"
          ]
          image_pull_policy = "Always"

          security_context {
              capabilities {
                  add = ["NET_ADMIN"]
              }
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "200Mi"
            }
          }
        }
      }
    }
  }
}



resource "kubernetes_deployment" "titania-api" {
  metadata {
    name = "titania-api"
    namespace = var.namespace
    labels = {
      app = "titania-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "titania-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "titania-api"
        }
      }

      spec {
        container {
          image = "sgryczan/titania-api:"${var.image_tag}""
          name  = "titania-api"

          port {
              name = "http"
              container_port = 8080
              protocol = "TCP"
          }
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "200Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/about"
              port = 80
            }
          }

          readiness_probe {
            http_get {
              path = "/about"
              port = 80
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "service" {
  metadata {
    name = "titania-api"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.titania-api.metadata.0.labels.app}"
    }
    port {
      name          = "http"
      port          = 80
      target_port   = "http"
      protocol      = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "titania-api"
    namespace = var.namespace
  }

  spec {
    backend {
      service_name = "titania-api"
      service_port = 80
    }

    rule {
      host = var.hostname
      http {
        path {
          backend {
            service_name = "titania-api"
            service_port = 80
          }

          path = "/"
        }
      }
    }
  }
}
