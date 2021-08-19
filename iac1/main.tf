provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    username = azurerm_kubernetes_cluster.k8s.kube_config.0.username
    password = azurerm_kubernetes_cluster.k8s.kube_config.0.password
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  username = azurerm_kubernetes_cluster.k8s.kube_config.0.username
  password = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "gitlab" {
  token = var.gitlab_token
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.67.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.3.2"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 2.23.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.6.0"
    }
  }
}

resource "azurerm_resource_group" "starwars" {
  location = var.location
  name = var.resource_group_name
}