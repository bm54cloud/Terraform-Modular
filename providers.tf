terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.24.1"
    }
  }
  required_version = ">= 1.1.5"
}

#Configure the AWS Provider
provider "aws" {
  region = var.variables_region
}