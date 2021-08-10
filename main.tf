resource "azurerm_resource_group" "k8s_rg" {
  name = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "master_nic" {
  name = "${var.vm_name}-master-nic"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location = var.location
  internal_dns_name_label = "${var.vm_name}-master"
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name = "${var.vm_name}-master-ipconf"
    subnet_id = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_machine" "master_vm" {
  name = "${var.vm_name}-master-vm"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location = var.location
  network_interface_ids = [azurerm_network_interface.master_nic.id]
  vm_size = var.vm_size
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = var.os_image_id
    publisher = var.os_image_id == "" ? var.os_image_publisher : ""
    offer = var.os_image_id == "" ? var.os_image_offer : ""
    sku = var.os_image_id == "" ? var.os_image_sku : ""
    version = var.os_image_id == "" ? var.os_image_version : ""
  }

  storage_os_disk {
    name = "${var.vm_name}-master-osdisk"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }

  os_profile {
    computer_name = "${var.vm_name}-master"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  lifecycle {
    ignore_changes = [tags,storage_image_reference]
  }
}

resource "azurerm_network_interface" "worker_nic" {
  count = var.vm_worker_count
  name = "${var.vm_name}-worker${count.index}-nic"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location = var.location
  internal_dns_name_label = "${var.vm_name}-worker${count.index}"
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name = "${var.vm_name}-worker${count.index}-ipconf"
    subnet_id = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_machine" "worker_vm" {
  count = var.vm_worker_count
  name = "${var.vm_name}-worker${count.index}-vm"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location = var.location
  network_interface_ids = [azurerm_network_interface.worker_nic[count.index].id]
  vm_size = var.vm_size
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = var.os_image_id
    publisher = var.os_image_id == "" ? var.os_image_publisher : ""
    offer = var.os_image_id == "" ? var.os_image_offer : ""
    sku = var.os_image_id == "" ? var.os_image_sku : ""
    version = var.os_image_id == "" ? var.os_image_version : ""
  }

  storage_os_disk {
    name = "${var.vm_name}-worker${count.index}-osdisk"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }

  os_profile {
    computer_name = "${var.vm_name}-worker${count.index}"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  lifecycle {
    ignore_changes = [tags,storage_image_reference]
  }
}