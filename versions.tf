terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = ">= 3.34, < 6.0"
    }
  }
}
