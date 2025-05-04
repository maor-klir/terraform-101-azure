# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3.0"
    }
  }
  # Configure the backend to store the state file in Azure Storage  
  backend "azurerm" {}
}

provider "azapi" {
}
