# Création de la ressource "azurerm_public_ip" pour l'adresse IP publique
resource "azurerm_public_ip" "publicip" {
  name                         = "20220505-public-ip"
  location                     = var.REGION
  resource_group_name          = var.RESOURCE_GROUP
  allocation_method            = "Static"
}

# Récupération du virtual network name
data "azurerm_virtual_network" "networkvnet" {
  name                 = "network-tp4"
  resource_group_name  = var.RESOURCE_GROUP
}


# Récupération du subnet ID
data "azurerm_subnet" "network-subnet" {
  name                 = "internal"
  resource_group_name  = var.RESOURCE_GROUP
  virtual_network_name = data.azurerm_virtual_network.networkvnet.name
}


# Création de la ressource "azurerm_network_interface" pour l'interface réseau
resource "azurerm_network_interface" "networkinterface" {
  name                = "20220505-network-interface"
  location            = var.REGION
  resource_group_name = var.RESOURCE_GROUP

  ip_configuration {
    name                          = "20220505-ip-config"
    subnet_id                     = data.azurerm_subnet.network-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}