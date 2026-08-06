data "azurerm_subnet" "example" {
    for_each = var.vms
  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

resource "azurerm_public_ip" "example" {
    for_each = var.vms
  name                = each.value.public_ip
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = each.value.allocation_method

  
}

resource "azurerm_network_interface" "example" {
    for_each = var.vms
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example[each.key].id
    public_ip_address_id = azurerm_public_ip.example[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
    for_each = var.vms
  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.example[each.key].id]
  vm_size               = each.value.vm_size
  

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
  name              = "${each.value.vm_name}-osdisk"
  caching           = "ReadWrite"
  create_option     = "FromImage"
  managed_disk_type = "Standard_LRS"
}
  os_profile {
    computer_name  = "hostname"
     admin_username = each.value.admin_user
    admin_password = each.value.admin_password
   
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}