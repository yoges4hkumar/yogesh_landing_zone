module "azurerm_resource_group" {
    source="../azurerm_resource_group"
    rgs= var.rg
  
}

module "virtual_network" {
    depends_on = [ module.azurerm_resource_group ]
    source="../virtual_network"
    vms = var.vnet
  
}

module "azurerm_subnet" {
    depends_on = [ module.virtual_network ]
    source = "../azurerm_subnet"
    vms = var.subnet
  
}

module "azurerm_nic_pip_vm" {
    depends_on = [ module.azurerm_resource_group , module.azurerm_subnet ]
    source = "../azurerm_nic_pip_vm"
    vms = var.vm
  
}