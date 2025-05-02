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
    resource_group_name  = "rg-terraform-101-terraform-state-dev"
    storage_account_name = "stterraform101au654k"
    container_name       = "tfstate"
    key                  = "devops-dev"
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
