resource "azurerm_kubernetes_cluster" "k8s" {
  dns_prefix = var.dns_prefix
  location = azurerm_resource_group.starwars.location
  name = var.cluster_name
  resource_group_name = azurerm_resource_group.starwars.name

  default_node_pool {
    name = "default"
    min_count = var.node_count.min
    max_count = var.node_count.max
    vm_size = var.node_size
    enable_auto_scaling = true
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "kubenet"
  }
}