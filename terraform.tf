terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "omni-network"
    workspaces {
      name = "blockscout"
    }
  }

  required_version = ">= 1.3.0"
}
