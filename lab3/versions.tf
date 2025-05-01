# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
  # Configure the backend to store the state file in Azure Storage  
  backend "azurerm" {
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
