# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.27.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3.0"
    }
  }
  # Configure the backend to store the state file in Azure Storage  
  backend "azurerm" {}
}

# Configure the Microsoft Azure Providers
provider "azurerm" {
  features {}
}
provider "azapi" {
}
