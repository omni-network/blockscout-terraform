locals {
  blockscout_dev_docker_image = "omniops/blockscout:dev"
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}


module "obs_staging_vpc" {
  source                                 = "./aws"
  count                                  = var.deploy_staging_blockscout ? 1 : 0
  vpc_name                               = "obs-staging"
  vpc_cidr                               = "10.104.0.0/16"
  ssl_certificate_arn                    = var.ssl_certificate_arn
  create_iam_instance_profile_ssm_policy = "true"
  deploy_ec2_instance_db                 = false
  deploy_rds_db                          = true
  xchain_settings = {
    enabled      = true
    docker_image = "omniops/xchain-indexer:latest"
    config       = "staging"
  }
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_dev_docker_image
    rpc_address             = "http://staging.omni.network:8545"
    ws_address              = "ws://staging.omni.network:8546"
    chain_id                = "165"
  }
  tags = {
    project           = "omni-staging-blockscout"
    terraform_managed = true
  }
  block_devices = [
    {
      device_name = "/dev/sda1"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]
}

module "obs_testnet_vpc" {
  source                                 = "./aws"
  vpc_name                               = "obs-testnet"
  vpc_cidr                               = "10.105.0.0/16"
  ssl_certificate_arn                    = var.ssl_certificate_arn
  create_iam_instance_profile_ssm_policy = "true"
  deploy_ec2_instance_db                 = false
  deploy_rds_db                          = true
  xchain_settings = {
    enabled      = false
    docker_image = "omniops/xchain-indexer:latest"
    config       = "staging"
  }
  blockscout_settings = {
    blockscout_docker_image = "omniops/blockscout:old"
    rpc_address             = "http://testnet-1-sentry-2.omni.network:8545"
    ws_address              = "ws://testnet-1-sentry-2.omni.network:8546"
    chain_id                = "165"
  }
  tags = {
    project           = "omni-testnet-blockscout"
    terraform_managed = true
  }
  block_devices = [
    {
      device_name = "/dev/sda1"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = false
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]
}

resource "cloudflare_record" "staging_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = "staging.explorer"
  type            = "CNAME"
  proxied         = false
  count           = var.deploy_staging_blockscout ? 1 : 0
  value           = var.deploy_staging_blockscout ? module.obs_staging_vpc[0].blockscout_url : null
  allow_overwrite = true
}

resource "cloudflare_record" "staging_xchain_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = "staging-xapi.explorer"
  type            = "CNAME"
  proxied         = false
  count           = var.deploy_staging_blockscout ? 1 : 0
  value           = var.deploy_staging_blockscout ? module.obs_staging_vpc[0].xchain_url : null
  allow_overwrite = true
}

resource "cloudflare_record" "testnet_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = "testnet-1.explorer"
  type            = "CNAME"
  proxied         = false
  value           = module.obs_testnet_vpc.blockscout_url
  allow_overwrite = true
}

output "staging_blockscout_url" {
  value = var.deploy_staging_blockscout ? module.obs_staging_vpc[0].blockscout_url : null
}

output "testnet_blockscout_url" {
  value = module.obs_testnet_vpc.blockscout_url
}
