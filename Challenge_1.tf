# Terraform versioning
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.40.0"
        }
    }

}

# Azure provider
provider "azurerm" { 
    features {}
}

# Main resource group 
resource "azurerm_resource_group" "vm-windows" {
    name = "main-resource"
    location = "westus2"
}

# Virtual network network1
resource "azurerm_virtual_network" "network1" {
    name = "net1"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.vm-windows.location 
    resource_group_name = azurerm_resource_group.vm-windows.name 
}

# Subnet for network1 
resource "azurerm_subnet" "subnet1" {
    name = "internal"
    resource_group_name = azurerm_resource_group.vm-windows.name
    virtual_network_name = azurerm_virtual_network.network1.name 
    address_prefixes = ["10.0.2.0/24"]
}

# NIC for virtual network 
resource "azurerm_network_interface" "nic1" {
    name = "network-int-card-1"
    location = azurerm_resource_group.vm-windows.location 
    resource_group_name = azurerm_resource_group.vm-windows.name 

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet1.id 
        private_ip_address_allocation = "Dynamic"
    }
}

#Virtual machine | 2016 WindowsServer 
resource "azurerm_windows_virtual_machine" "vm1" {
    name = "win-vm-2016-srv"
    resource_group_name = azurerm_resource_group.vm-windows.name 
    location = azurerm_resource_group.vm-windows.location 
    size = "Standard_B1s"
    admin_username = "REDACTED"
    admin_password = "REDACTED"
    network_interface_ids = [
        azurerm_network_interface.nic1.id,
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }
}
