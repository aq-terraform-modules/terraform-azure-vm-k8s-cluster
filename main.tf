resource "azurerm_resource_group" "k8s_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "controller_nic" {
  name                          = "controller-nic"
  resource_group_name           = azurerm_resource_group.k8s_rg.name
  location                      = var.location
  internal_dns_name_label       = "controller"
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "controller-ipconf"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_machine" "controller_vm" {
  name                             = "controller"
  resource_group_name              = azurerm_resource_group.k8s_rg.name
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.controller_nic.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.os_image_id
    publisher = var.os_image_id == "" ? var.os_image_publisher : ""
    offer     = var.os_image_id == "" ? var.os_image_offer : ""
    sku       = var.os_image_id == "" ? var.os_image_sku : ""
    version   = var.os_image_id == "" ? var.os_image_version : ""
  }

  storage_os_disk {
    name              = "controller-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }

  os_profile {
    computer_name  = "controller"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  zones = var.zones
  tags  = var.tags

  lifecycle {
    ignore_changes = [tags, storage_image_reference, zones]
  }
}

resource "azurerm_network_interface" "worker_nic" {
  count                         = var.vm_worker_count
  name                          = "worker-${count.index}-nic"
  resource_group_name           = azurerm_resource_group.k8s_rg.name
  location                      = var.location
  internal_dns_name_label       = "worker-${count.index}"
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "worker-${count.index}-ipconf"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_machine" "worker_vm" {
  count                            = var.vm_worker_count
  name                             = "worker-${count.index}"
  resource_group_name              = azurerm_resource_group.k8s_rg.name
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.worker_nic[count.index].id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.os_image_id
    publisher = var.os_image_id == "" ? var.os_image_publisher : ""
    offer     = var.os_image_id == "" ? var.os_image_offer : ""
    sku       = var.os_image_id == "" ? var.os_image_sku : ""
    version   = var.os_image_id == "" ? var.os_image_version : ""
  }

  storage_os_disk {
    name              = "worker-${count.index}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }

  os_profile {
    computer_name  = "worker-${count.index}"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  zones = var.zones
  tags  = var.tags

  lifecycle {
    ignore_changes = [tags, storage_image_reference]
  }
}
