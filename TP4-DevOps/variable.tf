# Variables de configuration

variable "VM_NAME" {
    type = string
    default = "devops-20220505"
}

variable "ADMIN_USERNAME" {
    type = string
    default = "devops"
}

variable "ADMIN_PASSWORD" {
    type = string
    default = "jenkins"
}

variable "REGION" {
    type = string
    default = "francecentral"
}

variable "RESOURCE_GROUP" {
    type = string
    default = "ADDA84-CTP"
}

variable "SSH_KEYS_PATH" {
    type = string
    default = "~/.ssh/"
}



