terraform {
  backend "azurerm" {
    storage_account_name = "{{TerraformStorageAccount}}"
    container_name       = "{{TerraformStorageContainer}}"
    access_key           = "{{InfraStorageKey}}"
    key                  = "{{TerraformStateKey}}"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.67.0"
    }
  }
}

resource "azurerm_kubernetes_cluster" "cluster" {
  dns_prefix                      = "{{environment}}"
  enable_pod_security_policy      = false
  kubernetes_version              = "{{kubernetesVersion}}"
  location                        = "eastus2"
  name                            = "{{client}}"
  node_resource_group             = "{{resourceGroup}}-infra"
  private_cluster_enabled         = false
  resource_group_name             = "{{resourceGroup}}"
  sku_tier                        = "Free"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    enable_auto_scaling          = false
    enable_host_encryption       = false
    enable_node_public_ip        = false
    max_pods                     = 250
    name                         = "agentpool"
    node_count                   = tonumber("{{nodeNumber}}")
    only_critical_addons_enabled = false
    orchestrator_version         = "{{kubernetesVersion}}"
    os_disk_size_gb              = 128
    os_disk_type                 = "Managed"
    tags                         = tomap({
      "env"      = "{{environment}}"
      "client"   = "{{client}}"
    })
    type                         = "VirtualMachineScaleSets"
    vm_size                      = "{{vmSize}}"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
  }

  tags                         = tomap({
    "env"      = "{{environment}}"
    "client"   = "{{client}}"
  })
}
