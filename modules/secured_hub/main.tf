# VWan Hub
resource "azurerm_virtual_hub" "hub" {
  name                = "vwan-hub-${var.location_short}-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_space
}

# Firewall
resource "azurerm_firewall" "hub_fw" {
  name                = "hub-fw-${var.location_short}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.azfw_sku_tier
  firewall_policy_id  = var.azfw_firewall_policy_id

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.hub.id
    public_ip_count = 1
  }
}

resource "azurerm_monitor_diagnostic_setting" "fw_diag_01" {
  name                       = "${azurerm_firewall.hub_fw.name}-diag"
  target_resource_id         = azurerm_firewall.hub_fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  lifecycle {
    ignore_changes = [metric]
  }
}

# Routing
resource "azurerm_virtual_hub_routing_intent" "hub_ri" {
  name           = "hub-ri-${var.location_short}-01"
  virtual_hub_id = azurerm_virtual_hub.hub.id

  routing_policy {
    name         = "TrafficPolicy"
    destinations = ["Internet", "PrivateTraffic"]
    next_hop     = azurerm_firewall.hub_fw.id
  }
}