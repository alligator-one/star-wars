# Azure Parameters
variable azure_client_id {}
variable azure_client_secret {}

# CloudFlare Parameters
variable cloudflare_email {}
variable cloudflare_api_key {}
variable cloudflare_zone_id {}

# GitLab Parameters
variable gitlab_token {}
variable backend_project_id {}
variable frontend_project_id {}

# Docker Registry Parameters
variable registry_server {}
variable registry_username {}
variable registry_password {}

# Environments settings
variable environments {
  default = {
    "test": {
      namespace: "starwars-test",
      subdomain: "test",
      host: "test.alligator-one.ru",
    },
    "prod": {
      namespace: "starwars-prod",
      subdomain: "@",
      host: "alligator-one.ru",
    }
  }
}

# Resource Group Parameters
variable resource_group_name {
  default = "starwars"
}

variable location {
  default = "West Europe"
}

# Cluster Parameters
variable node_count {
  default = {
    min: 1,
    max: 6
  }
}

variable node_size {
  default = "Standard_B2ms"
}

variable dns_prefix {
  default = "starwars-k8s"
}

variable cluster_name {
  default = "starwars-k8s"
}

# Log Analytics Parameters
variable log_analytics_workspace_name {
  default = "starwars-log-analytics"
}

variable log_analytics_workspace_sku {
  default = "PerGB2018"
}

# Application Gateway Parameters
variable application_gateway_name {
  default = "starwars-application-gateway"
}