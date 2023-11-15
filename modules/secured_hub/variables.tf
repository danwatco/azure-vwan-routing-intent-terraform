variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "location_short" {
  type = string  
}

variable "virtual_wan_id" {
  type = string
}

variable "address_space" {
  type = string
}

variable "azfw_sku_tier" {
  type = string
  default = "Standard"
}

variable "azfw_firewall_policy_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}