terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "1.2.4"
    }
  }
}

resource "helm_release" "nginx-ingress" {
  name             = var.release_name
  chart            = var.chart
  repository       = var.repository_url
  namespace        = var.namespace
  create_namespace = var.create_namespace
  wait             = var.wait
  replace          = var.replace

  dynamic "set" {
      for_each = var.settings

      content {
          name = set.key
          value = set.value
      }
  }
}