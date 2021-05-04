output "cluster_name"{
    value = azurerm_kubernetes_cluster.expertdays.name
}
output "cluster_rg" {
  value = azurerm_resource_group.expertdays.name
}

output "log_ws_id" {
  value = azurerm_log_analytics_workspace.expertdays.id
}

output "acr_id" {
  value = azurerm_container_registry.expertdays.id
}