terraform {
    backend "azurerm" {}
}

# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.46.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "expertdays" {
  name     = var.resource_group_name
  location = var.location
}

# Create Azure Container Registry
resource "azurerm_container_registry" "expertdays" {
  name                     = "expertdaysregistry"
  resource_group_name      = azurerm_resource_group.expertdays.name
  location                 = azurerm_resource_group.expertdays.location
  sku                      = "Standard"
  admin_enabled            = true
}

resource "azurerm_log_analytics_workspace" "expertdays" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.cluster_name}-log-workspace-567"
    location            = azurerm_resource_group.expertdays.location
    resource_group_name = azurerm_resource_group.expertdays.name
    sku                 = "PerGB2018"
}

resource "azurerm_virtual_network" "expertdays" {
  name                = "vnetexpertdays"
  location            = azurerm_resource_group.expertdays.location
  resource_group_name = azurerm_resource_group.expertdays.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "expertdays" {
  name                 = "subnetexpertdays"
  virtual_network_name = azurerm_virtual_network.expertdays.name
  resource_group_name  = azurerm_resource_group.expertdays.name
  address_prefixes     = ["10.1.0.0/22"]
}


resource "azurerm_kubernetes_cluster" "expertdays" {
  name                = var.cluster_name
  location            = azurerm_resource_group.expertdays.location
  resource_group_name = azurerm_resource_group.expertdays.name
  dns_prefix          = "expertdaysaks"

  default_node_pool {
    name       = "default"
    node_count = var.cluster_node_count
    vm_size    = var.cluster_node_vm_size
    vnet_subnet_id = azurerm_subnet.expertdays.id
  }

  identity { 
    type = "SystemAssigned" 
  }

#  service_principal {
#    client_id     = var.cluster_sp_client_id
#    client_secret = var.cluster_sp_client_secret
#  }

  network_profile {
    network_plugin    = "kubenet"
  }
}

