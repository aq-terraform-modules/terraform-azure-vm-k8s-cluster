variable "resource_group_name" {
  description = "Resource group name"
}

variable "location" {
  description = "Location of resources"
}

variable "vm_name" {
  description = "VM name"
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking or not"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
}

variable "private_ip_address_allocation" {
  description = "Type of address allocation"
  default     = "Dynamic"
}

variable "vm_size" {
  description = "Default size of the VM"
  default     = "Standard_B2s"
}

variable "os_image_id" {
  description = "ID of the custom OS image"
  default     = ""
}

variable "os_image_publisher" {
  description = "Publisher of the OS image"
  default     = "Canonical"
}

variable "os_image_offer" {
  description = "Offer of the OS image"
  default     = "0001-com-ubuntu-server-focal"
}

variable "os_image_sku" {
  description = "SKU of the OS image"
  default     = "20_04-lts-gen2"
}

variable "os_image_version" {
  description = "Version of the OS image"
  default     = "latest"
}

variable "os_disk_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Standard_LRS"
}

variable "admin_username" {
  description = "Admin username of the VM"
}

variable "ssh_public_key" {
  description = "Public key for SSH"
}

variable "vm_worker_count" {
  description = "Number of worker VMs"
  default     = 2
}

variable "tags" {
  description = "Tag for resources"
  type = map(any)
  default = {
    environment = "dev"
  }
}

variable "zones" {
  description = "Availability Zones for the VM"
  type = list(any)
  default = []
}