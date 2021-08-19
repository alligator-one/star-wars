resource "local_file" "kubeconfig" {
  filename = "kubeconfig.yml"
  content = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

output "grafana_password" {
  value = random_password.grafana_password.result
  sensitive = true
}

output "database_uri" {
  value = azurerm_cosmosdb_account.database.connection_strings[0]
  sensitive = true
}
