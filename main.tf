provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  omni_staging_rpc = "http://staging.omni.network:8545"
  external_chains_staging_config = {
      "external_chains": [
        {
          "chain_name": "optimism-goerli",
          "rpc_addr": "https://optimism-goerli.infura.io/v3/dc5009d7603b431799765f8de1dfff6c",
          "default_start_block": -1,
          "confirmation_block_count": 10,
          "syncInterval": 30,
          "portal_addr": "0x0100B6119B26A9dE68865E4f34ad2125bd83e9D1"
        },
        {
          "chain_name": "arbitrum-goerli",
          "rpc_addr": "https://arbitrum-goerli.infura.io/v3/dc5009d7603b431799765f8de1dfff6c",
          "default_start_block": -1,
          "confirmation_block_count": 10,
          "syncInterval": 30,
          "portal_addr": "0x0100B6119B26A9dE68865E4f34ad2125bd83e9D1"
        }
      ]
  }
  external_chains_testnet_config = {}
  omni_testnet_rpc = "https://testnet.omni.network"
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
    docker_image = var.xchain_indexer_docker_image
    config       = "staging"
    omni_config = {
      omni_rpc = local.omni_staging_rpc
    }
    extrenal_chains_config = local.external_chains_staging_config
  }
  blockscout_settings = {
    blockscout_docker_image = var.staging_blockscout_docker_image
    rpc_address             = "http://staging.omni.network:8545"
    ws_address              = "ws://staging.omni.network:8546"
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
    docker_image = var.xchain_indexer_docker_image
    config       = "testnet"
    omni_config = {
      omni_rpc = local.omni_testnet_rpc
    },
    extrenal_chains_config = local.external_chains_testnet_config
  }
  blockscout_settings = {
    blockscout_docker_image = var.testnet_blockscout_docker_image
    rpc_address             = "http://testnet-sentry-explorer.omni.network:8545"
    ws_address              = "ws://testnet-sentry-explorer.omni.network:8546"
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
