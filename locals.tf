locals {
  region_map = {
    "UK South"    = "uks"
    "West Europe" = "weu"
  }


  vm1_region1_name = "vm1-${local.region_map[var.region1]}"
  vm1_region2_name = "vm1-${local.region_map[var.region2]}"
}