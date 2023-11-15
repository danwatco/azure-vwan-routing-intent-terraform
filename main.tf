# Resource Group for the Virtual WAN
resource "azurerm_resource_group" "vwan_rg" {
  name     = "rg-vwan"
  location = var.region1
}

# Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-${local.region_map[var.region1]}-01"
  resource_group_name = azurerm_resource_group.vwan_rg.name
  location            = azurerm_resource_group.vwan_rg.location
}

# LAW
resource "azurerm_log_analytics_workspace" "law1" {
  name                = "law-${local.region_map[var.region1]}-01"
  location            = azurerm_resource_group.vwan_rg.location
  resource_group_name = azurerm_resource_group.vwan_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Central Firewall Policy
resource "azurerm_firewall_policy" "hub_fw_pol" {
  name                = "fw-pol-01"
  resource_group_name = azurerm_resource_group.vwan_rg.name
  location            = azurerm_resource_group.vwan_rg.location
}

# Firewall Policy Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "hub_fw_pol_rcg" {
  name               = "fw-pol-rcg-01"
  firewall_policy_id = azurerm_firewall_policy.hub_fw_pol.id
  priority           = 200

  network_rule_collection {
    name     = "nrc-01"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "AllowDNS"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["168.63.129.16"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "AllowPrivate"
      protocols             = ["UDP", "TCP", "ICMP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["1-65535"]
    }

    rule {
      name                  = "AllowICMP"
      protocols             = ["ICMP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["1-65535"]
    }

    rule {
      name                  = "AllowNTP"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "AllowRDPInbound"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["3389"]
    }

    rule {
      name                  = "AllowAzureUpdate"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureUpdateDelivery"]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "arc-01"
    priority = 201
    action   = "Allow"
    rule {
      name = "AllowGoogle"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.google.com"]

    }
  }

}