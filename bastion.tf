# Bastion Resources

# RG
resource "azurerm_resource_group" "bastion_rg" {
  name     = "rg-bastion-${local.region_map[var.region1]}"
  location = var.region1
}

resource "azurerm_virtual_network" "bastion_vnet" {
  name                = "vnet-bastion-${local.region_map[var.region1]}-01"
  resource_group_name = azurerm_resource_group.bastion_rg.name
  location            = azurerm_resource_group.bastion_rg.location
  address_space       = ["10.50.0.0/16"]

  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = "10.50.0.0/24"
  }

}

resource "azurerm_virtual_hub_connection" "bastion_hub_connection" {
  name                      = "vwan-hub-connection-bastion-${local.region_map[var.region1]}"
  virtual_hub_id            = module.secured_hub_region1.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.bastion_vnet.id
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_uks" {
  name                = "bastion-${local.region_map[var.region1]}-std"
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name
  sku                 = "Standard"
  ip_connect_enabled  = true

  ip_configuration {
    name                 = "bastion-ipconfig"
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
    subnet_id            = azurerm_virtual_network.bastion_vnet.subnet.*.id[0]
  }
}