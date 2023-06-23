# Génération d'une paire de clés SSH
resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Écriture de la clé publique dans un fichier
resource "local_file" "mykey_pub" {
  filename = "${path.module}/mykey.pem"
  content  = tls_private_key.mykey.private_key_pem
}

# Création de la ressource "azurerm_virtual_machine" pour la machine virtuelle
resource "azurerm_linux_virtual_machine" "devops-20220505" {
  name                  = var.VM_NAME
  location              = var.REGION
  resource_group_name   = var.RESOURCE_GROUP
  network_interface_ids = [azurerm_network_interface.networkinterface.id]
  size               = "Standard_D2s_v3"

  os_disk {
    name              = "20220505-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

    computer_name  = var.VM_NAME
    admin_username = var.ADMIN_USERNAME
    disable_password_authentication = true

  admin_ssh_key {
    username   = var.ADMIN_USERNAME
    public_key = tls_private_key.mykey.public_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
    ]

    connection {
    type        = "ssh"
    user        = var.ADMIN_USERNAME
    private_key = tls_private_key.mykey.private_key_pem
    host        = azurerm_linux_virtual_machine.devops-20220505.public_ip_address
  }
  }
}