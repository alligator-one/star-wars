// Kubeconfig
resource "gitlab_project_variable" "backend-kubeconfig" {
  key = "KUBERNETES_CONFIG"
  variable_type = "file"
  project = var.backend_project_id
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

resource "gitlab_project_variable" "frontend-kubeconfig" {
  key = "KUBERNETES_CONFIG"
  variable_type = "file"
  project = var.frontend_project_id
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

// Namespaces
resource "kubernetes_namespace" "app-namespace" {
  for_each = var.environments
  metadata {
    name = each.value.namespace
  }
}

resource "gitlab_project_variable" "backend-namespace" {
  for_each = kubernetes_namespace.app-namespace
  key = "KUBERNETES_NAMESPACE"
  project = var.backend_project_id
  value = each.value.metadata[0].name
  environment_scope = each.key
}

resource "gitlab_project_variable" "frontend-namespace" {
  for_each = kubernetes_namespace.app-namespace
  key = "KUBERNETES_NAMESPACE"
  project = var.frontend_project_id
  value = each.value.metadata[0].name
  environment_scope = each.key
}

// Ingresses
resource "kubernetes_ingress" "app-ingress" {
  for_each = var.environments
  metadata {
    name = "starwars-ingress"
    namespace = each.value.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = each.value.host
      http {
        path {
          path = "/api"
          backend {
            service_name = "swapp-backend-starwars-backend"
            service_port = "8000"
          }
        }
        path {
          path = "/"
          backend {
            service_name = "swapp-frontend-starwars-frontend"
            service_port = "80"
          }
        }
      }
    }
  }
}

// Docker pull secrets
resource "kubernetes_secret" "docker-config" {
  for_each = kubernetes_namespace.app-namespace
  metadata {
    name = "docker-config"
    namespace = each.value.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.registry_server}": {
      "auth": "${base64encode("${var.registry_username}:${var.registry_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}

//App records
resource "cloudflare_record" "app-records" {
  for_each = var.environments
  name = each.value.subdomain
  type = "A"
  zone_id = var.cloudflare_zone_id
  value = data.kubernetes_service.ingress-nginx-service.status.0.load_balancer.0.ingress.0.ip
  proxied = true
}
