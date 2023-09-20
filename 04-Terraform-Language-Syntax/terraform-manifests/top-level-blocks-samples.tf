#####################################################################
# Block-1: Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
# Terraform State Storage to Azure Storage Container
  # backend "azurerm" {
  #   resource_group_name   = "my_demo_rg1"
  #   storage_account_name  = "terraformstate201"
  #   container_name        = "tfstatefiles"
  #   key                   = "terraform.tfstate"
  # }   
}

#####################################################################
# Block-2: Provider Block
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

#####################################################################
# Block-3: Resource Block
# Create Resource Group 
resource "azurerm_resource_group" "myrg" {
  location = "eastasia"
  name = "my-demo-rg1"  
}
# Create Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.myrg.location
  resource_group_name = data.azurerm_resource_group.myrg.name
}
#####################################################################
# Block-4: Input Variables Block
# Define a Input Variable for Azure Region 
variable "azure_region" {
  default = "eastus"
  description = "Azure Region where resources to be created"
  type = string
}
#####################################################################
# Block-5: Output Values Block
# Output the Azure Resource Group ID 
output "azure_resourcegroup_id" {
  description = "My Azure Resource Group ID"
  value = data.azurerm_resource_group.myrg.id 
}
#####################################################################
# Block-6: Local Values Block
# Define Local Value with Business Unit and Environment Name combined
# locals {
#   name = "${var.business_unit}-${var.environment_name}"
# }
#####################################################################
# Block-7: Data sources Block
# Use this data source to access information about an existing Resource Group.
data "azurerm_resource_group" "example" {
  name = "my-demo-rg1"
}
output "id" {
  value = data.azurerm_resource_group.example.id
}
#####################################################################
# Block-8: Modules Block
# Azure Virtual Network Block using Terraform Modules (https://registry.terraform.io/modules/Azure/network/azurerm/latest)
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = data.azurerm_resource_group.example.name
  address_spaces      = ["10.0.0.0/16", "10.2.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  use_for_each = "true"
  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  # depends_on = [data.azurerm_resource_group.example]
}
#####################################################################
