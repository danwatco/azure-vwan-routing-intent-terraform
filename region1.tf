# UK South Hub Resources

# RG
resource "azurerm_resource_group" "region1_rg" {
  name     = "rg-hub-${local.region_map[var.region1]}-01"
  location = var.region1
}

module "secured_hub_region1" {
  source = "./modules/secured_hub"

  resource_group_name = azurerm_resource_group.region1_rg.name
  location            = azurerm_resource_group.region1_rg.location
  location_short = local.region_map[var.region1]
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_space       = "10.0.0.0/16"
  azfw_firewall_policy_id = azurerm_firewall_policy.hub_fw_pol.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law1.id

}

# Vnet 
resource "azurerm_virtual_network" "vnet1_region1" {
  name                = "vnet-${local.region_map[var.region1]}-01"
  resource_group_name = azurerm_resource_group.region1_rg.name
  location            = azurerm_resource_group.region1_rg.location
  address_space       = ["10.10.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.10.0.0/24"
    security_group = azurerm_network_security_group.vnet1_nsg.id
  }

}

# NSG
resource "azurerm_network_security_group" "vnet1_nsg" {
  name                = "vnet-${local.region_map[var.region1]}-01-nsg"
  location            = azurerm_resource_group.region1_rg.location
  resource_group_name = azurerm_resource_group.region1_rg.name

  lifecycle {
    ignore_changes = [ security_rule ]
  }
}

resource "azurerm_virtual_hub_connection" "vnet1_hub_connection" {
  name                      = "vwan-hub-connection-vnet1-${local.region_map[var.region1]}"
  virtual_hub_id            = module.secured_hub_region1.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.vnet1_region1.id
  internet_security_enabled = true
}

# Virtual Machine
resource "azurerm_network_interface" "vm1_nic" {
  name                = "${local.vm1_region1_name}-nic"
  location            = azurerm_resource_group.region1_rg.location
  resource_group_name = azurerm_resource_group.region1_rg.name

  ip_configuration {
    name                          = "${local.vm1_region1_name}-ipconfig"
    subnet_id                     = azurerm_virtual_network.vnet1_region1.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm1_region1" {
  name                = local.vm1_region1_name
  resource_group_name = azurerm_resource_group.region1_rg.name
  location            = azurerm_resource_group.region1_rg.location
  size                = "Standard_D2s_v3"

  admin_username = "azureuser"
  admin_password = "Pa$$w0rd123!"
  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}