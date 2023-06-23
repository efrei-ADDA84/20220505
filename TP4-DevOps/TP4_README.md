# **DevOps TP4 - Terraform + Azure Virtual Machines**


<image src="https://blog.jcorioland.io/images/terraform-microsoft-azure-introduction/terraform-azure.png" width=1000 center>

[<img src="https://img.shields.io/badge/Terraform-ARM64 1.5.1-blue.svg?logo=terraform">](https://github.com/efrei-ADDA84/20220505/actions/workflows/docker-image.yml)                                             [<img src="https://img.shields.io/badge/Azure Virtual Machine-devops--20220505-blue.svg?logo=microsoftazure">]()                                              [<img src="https://img.shields.io/badge/Scripts-bash/zsh-important.svg?logo=gnubash">](https://pypi.org/project/requests/)                                  

<br />

***
***
<br />

## **SYNOPSIS**

Ce projet vise à créer une `Azure Virtual Machine (AVM)` à partir de l'outil `Terraform`. La AVM devra être accessible à distance via une connexion SSH.

<br />

***
***
<br />

## **REVUE TECHNIQUE**

> ### **<u>Créer le Provider</u>**

Le fichier `provider.tf` contient les éléments nécessaires à l'initialisation de l'environnement `Terraform`. Son contenu est le suivant:

```js
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

// Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
  tenant_id       = "413600cf-bd4e-4c7c-8a61-69e73cddf731"
}
```
Ce code est utilisé pour configurer le `fournisseur Terraform` pour `Microsoft Azure`. Le bloc `terraform` configure les fournisseurs requis pour ce code Terraform. Dans ce cas, le fournisseur `azurerm` est requis avec une version spécifique `3.0.0`.

Le bloc `provider` configure le fournisseur `azurerm` avec les informations d'identification nécessaires pour se connecter à notre compte Azure. `subscription_id` est l'ID de notre abonnement Azure et `tenant_id` est l'ID de notre locataire Azure.

***
<br />

> ### **<u>Créer les variables</u>**

Le fichier `variable.tf` les variables utilisés dans les codes `Terraform`. Les variables sont utilisées pour rendre le code Terraform plus flexible et permettre aux utilisateurs de personnaliser le déploiement en fonction de leurs besoins. Son contenu est le suivant:

```js
// Variables de configuration

variable "VM_NAME" {
  type    = string
  default = "devops-20220505"
}

variable "ADMIN_USERNAME" {
  type    = string
  default = "devops"
}

variable "REGION" {
  type    = string
  default = "francecentral"
}

variable "RESOURCE_GROUP" {
  type    = string
  default = "ADDA84-CTP"
}
```

Dans ce cas, les variables définies incluent le nom de la machine virtuelle (`VM_NAME`), le nom d'utilisateur de l'administrateur (`ADMIN_USERNAME`), la région de déploiement (`REGION`) et le groupe de ressources dans Azure (`RESOURCE_GROUP`).

Les variables sont définies avec un type et une valeur par défaut. Le type peut être string, number, bool ou list. La valeur par défaut est utilisée si aucune autre valeur n'est fournie lors de l'exécution du code Terraform.

***
<br />

> ### **<u>Configurer le système réseau associé à la machine virtuelle</u>**

Pour réaliser la configuration réseau de la VM (Virtual machine), nous créerons des ressources Microsoft Azure à partir du code `Terraform` suivant (network.tf):

```js
// Création de la ressource "azurerm_public_ip" pour ladresse IP publique
resource "azurerm_public_ip" "publicip" {
  name                = "20220505-public-ip"
  location            = var.REGION
  resource_group_name = var.RESOURCE_GROUP
  allocation_method   = "Static"
}

// Récupération du virtual network name
data "azurerm_virtual_network" "networkvnet" {
  name                = "network-tp4"
  resource_group_name = var.RESOURCE_GROUP
}


// Récupération du subnet ID
data "azurerm_subnet" "network-subnet" {
  name                 = "internal"
  resource_group_name  = var.RESOURCE_GROUP
  virtual_network_name = data.azurerm_virtual_network.networkvnet.name
}


// Création de la ressource "azurerm_network_interface" pour l'interface réseau
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
```

Les ressources créées sont une adresse IP publique (`azurerm_public_ip`), un réseau virtuel (`azurerm_virtual_network`), un sous-réseau (`azurerm_subnet`) et une interface réseau (`azurerm_network_interface`).

L'adresse IP publique est créée en premier, puis le nom du réseau virtuel est récupéré à partir des données existantes dans Azure. Le sous-réseau est ensuite récupéré en utilisant à la fois le nom du réseau virtuel et le nom du sous-réseau. Enfin, l'interface réseau est créée avec une configuration IP pour le sous-réseau et l'adresse IP publique créée précédemment.

Les valeurs des paramètres sont définies à l'aide de variables `Terraform`, telles que `var.REGION` et `var.RESOURCE_GROUP`, pour permettre une personnalisation facile.

***
<br />

> ### **<u>Créer la AVM (Azure Virtual Machine)</u>**

On créé enfin la AVM en prenant en compte le fait qu'il soit accessible via une connexion SSH distante. On veut également qu'à la création de cette ressource, le daemon `Docker` soit autmoatiquement installé sur la AVM. Le code de `vm.tf` est le suivant:

```js
// Génération d'une paire de clés SSH
resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Écriture de la clé privée dans un fichier
resource "local_file" "mykey_pub" {
  filename = "${path.module}/mykey.pem"
  content  = tls_private_key.mykey.private_key_pem
}

// Création de la ressource "azurerm_virtual_machine" pour la machine virtuelle
resource "azurerm_linux_virtual_machine" "devops-20220505" {
  name                  = var.VM_NAME
  location              = var.REGION
  resource_group_name   = var.RESOURCE_GROUP
  network_interface_ids = [azurerm_network_interface.networkinterface.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "20220505-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name                   = var.VM_NAME
  admin_username                  = var.ADMIN_USERNAME
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
```

La clé SSH est générée à l'aide de la ressource `tls_private_key`, et la clé privée est écrite dans un fichier local (`mykey.pem`) à l'aide de la ressource `local_file`. La machine virtuelle est créée à l'aide de la ressource `azurerm_linux_virtual_machine`. Les paramètres comprennent le nom de la machine virtuelle, la région de déploiement, le groupe de ressources Azure dans lequel la machine virtuelle sera créée, la taille de la machine virtuelle, le disque OS, l'image source, le nom d'utilisateur administrateur, et la clé SSH publique.

La provision `remote-exec` est utilisée pour installer `Docker` sur la machine virtuelle. Cette provision exécute des commandes shell à distance sur la machine virtuelle. Les commandes shell exécutées sont les suivantes : mise à jour des paquets, installation de paquets Docker, ajout de la clé de Docker et installation de Docker.

Le bloc `connection` définit les informations de connexion pour la connexion SSH. Les paramètres comprennent le type de connexion (SSH dans ce cas), le nom d'utilisateur administrateur, la clé privée SSH et l'adresse IP publique de la machine virtuelle.

>>**N.B:** Un provisioner Terraform est un bloc de code qui permet de configurer ou de provisionner des ressources après leur création. Les provisioners sont utilisés pour automatiser les tâches de configuration et de gestion des ressources, telles que l'installation de logiciels, la configuration de services, la copie de fichiers,...

<br/>

> ### **<u>Outputs</u>**
Le fichier `outputs.tf` permet de récupérer à la fin de la création de la `AVM`, L'adresse IP publique de la AVM. Son contenu est le suivant:
```js
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.devops-20220505.public_ip_address
}
```
<br />


> ### **<u>Bash/Zsh scripts**
Afin de faciliter l'exécution du projet, deux scripts Bash ont été définis: `setup.sh` et `destroy.sh`. Le premier permet d'exécuter tout le projet en créant toutes les ressources annexes et la AVM. Après cette étape, on peut tester la connexion SSH distante et l'installation effective du daemon Docker. Le second fichier permet de détruire toutes les ressources Microsoft Azure créées.

Le contenu de `setup.sh`:
```sh
echo "TP4-DevOps Execution"

echo "TERRAFORM INIT EXECUTION"
terraform init

echo "=========================================================="
echo "\n\n TERRAFORM APPLY EXECUTION"
terraform apply

chmod 700 mykey.pem

echo "=========================================================="
echo "\n\n TERRAFORM CODE FORMATTING EXECUTION"
terraform fmt

sleep 2

clear

echo "Fin du processus !"

clear

sleep 2

echo "PUBLIC IP ADRESS : "
terraform output public_ip_address
```

Le contenu de `destroy.sh`:
```sh
echo "TP4-DevOps Destroy all Terraform created resources"

echo "TERRAFORM DESTROY EXECUTION"
terraform destroy

sleep 2

clear

echo "Fin du processus !"

sleep 2

clear
```
<br />

***
***
<br />

## **EXÉCUTION**
Pour exécuter ce TP, se placer dans le répertoire `TP4-DevOps`, puis exécuter la commande suivante pour créer les ressources et la AVM:

```sh
> chmod u+x setup.sh
> sh setup.sh
```

On peut tester ensuite la connexion distante SSH avec:

```sh
> ssh -i 20220505/TP4-DevOps/mykey.pem devops@{AVM Public IP Adress}

Last login: Fri Jun 23 14:51:18 2023 from ******
devops@devops-20220505:~$
```

Pour tester l'installation effective du daemon Docker sur la AVM puis se déconnecter, exécuter (en étant connecté via SSH):

```sh
devops@devops-20220505:~$ sudo docker info

Client:
 Context:    default
 Debug Mode: false
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Build with BuildKit (Docker Inc., v0.5.1-docker)
  scan: Docker Scan (Docker Inc., v0.8.0)
...
WARNING: No swap limit support

devops@devops-20220505:~$ exit
logout
Connection to 51.103.49.197 closed.

>
```

Enfin après toutes les manipulations, si on souhaite supprimer les ressources créées au début, il suffit d'exécuter le script `destroy.sh`:

```sh
> chmod u+x destroy.sh
> sh destroy.sh
```

<br />

***
***
<br />

## **TESTS TECHNIQUES**

> ### **<u>Formattage du code Terraform</u>**
Il suffit d'exécuter la commande suivante en se plaçant dans le répertoire `TP4-DevOps` :
```sh
> terraform fmt
```
**<u>N.B</u>: On retrouve ce formattage dans le fichier** `setup.sh`

<br />
    
***
***
    
<br />
    
## **COMMENTAIRES : INTÉRÊT DE L'UTILISATION DE TERRAFORM POUR DÉPLOYER DES RESSOURCES SUR LE CLOUD PLUTÔT QUE LA CLI**

`Terraform` est un outil d'`infrastructure as code (IaC)` qui permet de déployer des ressources sur le cloud de manière reproductible et transparente. Contrairement à la `CLI`, `Terraform` permet de décrire l'infrastructure souhaitée dans un fichier de configuration (`.tf`), ce qui facilite la gestion des modifications, la collaboration et la reproductibilité.

En outre, `Terraform` prend en charge plusieurs fournisseurs de cloud, ce qui permet de déployer des ressources sur différentes plateformes avec la même syntaxe. `Terraform` permet également de gérer des ressources complexes en utilisant des modules réutilisables, ce qui facilite la gestion de l'infrastructure à grande échelle.

Enfin, `Terraform` permet de planifier les modifications avant de les appliquer, ce qui permet de vérifier les changements avant de les déployer, ce qui peut éviter des erreurs coûteuses. Dans l'ensemble, l'utilisation de `Terraform` pour déployer des ressources sur le cloud offre de nombreux avantages par rapport à la `CLI`.

<br />
    
***
***

<br />

## **COMMENTAIRES AVM(Azure Virtual Machine) Vs. ACI(Azure Container Instance)**

`Azure Container Instances (ACI)` et `Azure Virtual Machines (AVM)` sont deux services différents proposés par `Microsoft Azure` pour exécuter des applications dans le cloud.

`ACI` est un service d'exécution de conteneurs, qui permet de déployer rapidement des conteneurs `Docker` sans avoir à gérer les serveurs sous-jacents. `ACI` est idéal pour les applications à courte durée de vie ou pour les tests et les déploiements de développement. `ACI` est facturé à l'utilisation, ce qui signifie que vous payez uniquement pour le temps d'exécution réel de vos conteneurs.

`AVM` est un service de machine virtuelle, qui permet de déployer des machines virtuelles complètes dans le cloud. `AVM` offre une grande flexibilité et peut être utilisé pour exécuter pratiquement n'importe quelle application. `AVM` est facturé à l'heure d'utilisation, ce qui signifie que vous payez pour le temps d'exécution de votre machine virtuelle, indépendamment de son état d'activité.

En résumé, `ACI` est idéal pour les applications à courte durée de vie ou pour les tests et les déploiements de développement, tandis qu'`AVM` est plus adapté pour les applications à long terme ou les applications nécessitant une grande flexibilité.

<br />
    
***
***

<br />

## **CRÉDITS**

<image src="https://frimpong-adotri-01.github.io/mywebsite/pictures/me.png" width=200 center>  

**AUTEUR :** ADOTRI Frimpong

**PROMO :** Big Data & Machine Learning (EFREI)

**PROFESSEUR :** DOMINGUES Vincent

**COPYRIGHT :** Juin 2023

***
***
