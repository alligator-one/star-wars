resource "azurerm_cosmosdb_account" "database" {
  name = "starwars-database"
  resource_group_name = azurerm_resource_group.starwars.name
  location = azurerm_resource_group.starwars.location
  kind = "MongoDB"
  offer_type = "Standard"
  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = 400
    max_staleness_prefix = 200000
  }
  geo_location {
    failover_priority = 0
    location = azurerm_resource_group.starwars.location
  }
}

resource "azurerm_cosmosdb_mongo_database" "database" {
  for_each = var.environments
  name = "starwars-${each.key}"
  resource_group_name = azurerm_cosmosdb_account.database.resource_group_name
  account_name = azurerm_cosmosdb_account.database.name
  throughput = 400
}

resource "kubernetes_secret" "database" {
  for_each = kubernetes_namespace.app-namespace
  metadata {
    name = "database-uri"
    namespace = each.value.metadata[0].name
  }
  data = {
    "uri": azurerm_cosmosdb_account.database.connection_strings[0]
    "name": "starwars-${each.key}"
  }
}