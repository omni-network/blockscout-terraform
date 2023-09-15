provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

/* For each deployment of new docker images for xchain indexer and\or blockscout to any enviroment, 
   make sure to use specific tag names in the vars given below (i.e "omniops/xchain-indexer:1.0.0") 
  and to commit the change to the repo once the deployment has been executed. This is currently the only place
  where we track which version of a docker image has been deployed to an enviroment.
*/
locals {
  omni_staging_rpc = "http://staging.omni.network:8545"
  omni_staging_ws = "ws://staging.omni.network:8546"
  xchain_indexer_staging_docker_image = "omniops/xchain-indexer:latest"
  blockscout_staging_docker_image = "omniops/blockscout:latest"
  omni_testnet_rpc = "http://testnet-sentry-explorer.omni.network:8545"
  omni_testnet_ws = "ws://testnet-sentry-explorer.omni.network:8546"
  xchain_indexer_testnet_docker_image = "omniops/xchain-indexer:master"
  blockscout_testnet_docker_image = "omniops/blockscout:master"
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
    docker_image = local.xchain_indexer_staging_docker_image
    config       = "staging"
    omni_config = {
      omni_rpc = local.omni_staging_rpc
    }
  }
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_staging_docker_image
    rpc_address             = local.omni_staging_rpc
    ws_address              = local.omni_staging_ws
    chain_id                = "165"
    docker_shell            = "sh"
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
  count                                  = var.deploy_testnet_blockscout ? 1 : 0
  vpc_name                               = "obs-testnet"
  vpc_cidr                               = "10.105.0.0/16"
  ssl_certificate_arn                    = var.ssl_certificate_arn
  create_iam_instance_profile_ssm_policy = "true"
  deploy_ec2_instance_db                 = false
  deploy_rds_db                          = true
  xchain_settings = {
    enabled      = true
    docker_image = local.xchain_indexer_testnet_docker_image
    config       = "testnet"
    omni_config = {
      omni_rpc = local.omni_testnet_rpc
    }
  }
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_testnet_docker_image
    rpc_address             = local.omni_testnet_rpc
    ws_address              = local.omni_testnet_ws
    chain_id                = "165"
    docker_shell            = "sh"
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

resource "cloudflare_record" "testnet_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = "testnet.explorer"
  type            = "CNAME"
  proxied         = false
  count           = var.deploy_testnet_blockscout ? 1 : 0
  value           = var.deploy_testnet_blockscout ? module.obs_testnet_vpc[0].blockscout_url : null
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

resource "cloudflare_record" "testnet_xchain_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = "testnet-xapi.explorer"
  type            = "CNAME"
  proxied         = false
  count           = var.deploy_testnet_blockscout ? 1 : 0
  value           = var.deploy_testnet_blockscout ? module.obs_testnet_vpc[0].xchain_url : null
  allow_overwrite = true
}

output "staging_blockscout_url" {
  value = var.deploy_staging_blockscout ? module.obs_staging_vpc[0].blockscout_url : null
}

output "testnet_blockscout_url" {
  value = var.deploy_testnet_blockscout ? module.obs_testnet_vpc[0].blockscout_url : null
}
