terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.115.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstate23952"
    container_name       = "tfstatefiles"
    key                  = "terraform.tfstate"
  }
}
# Configuration options
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "random" {
  # Configuration options
}
# provider for another region
# provider "azurerm" {
#   skip_provider_registration = true
#   features {
#     virtual_machine {
#       delete_os_disk_on_deletion = false
#     }
#   }
#     alias = "provider2-westus"
# }
