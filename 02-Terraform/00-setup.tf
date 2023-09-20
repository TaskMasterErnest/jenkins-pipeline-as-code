# Initialize Terraform and the AWS Providers
# The random provider provides resources that generate random values during their creation and then hold those values steady until the inputs are changed.
# The HTTP provider is a utility provider for interacting with generic HTTP servers as part of a Terraform configuration.
terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # https://registry.terraform.io/providers/hashicorp/aws/latest
      version = "~> 5.0"
    }
    http = {
      source = "hashicorp/http" # https://registry.terraform.io/providers/hashicorp/http/latest
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}