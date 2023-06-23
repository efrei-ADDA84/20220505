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