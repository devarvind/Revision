resource "azurerm_resource_group" "testrg" {
  name     = "test-rg"
  location = "central india"
}
resource "azurerm_storage_account" "teststorage" {
  depends_on               = [azurerm_resource_group.testrg]
  name                     = "arvindstoragesg"
  resource_group_name      = "test-rg"
  location                 = "central india"
  account_tier             = "Standard"
  account_replication_type = "LRS"


}
resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
}
resource "azurerm_subnet" "subnet" {
  depends_on           = [azurerm_resource_group.testrg, azurerm_virtual_network.vnet]
  name                 = "test-subnet"
  resource_group_name  = "test-rg"
  virtual_network_name = "test-vnet"
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "pip" {
  depends_on          = [azurerm_resource_group.testrg]
  name                = "test-public-ip"
  resource_group_name = "test-rg"
  location            = "central india"
  allocation_method   = "Static"

}
resource "azurerm_network_interface" "nic" {
  name                = "test-nic"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "test-vm"
  location                        = azurerm_resource_group.testrg.location
  resource_group_name             = azurerm_resource_group.testrg.name
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "adminuser@123"
  network_interface_ids           = [azurerm_network_interface.nic.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}