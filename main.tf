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
  omni_staging_ws = "ws://staging.omni.network:8546"
  omni_chain_config_staging = {
    rpc_addr = "http://staging.omni.network:8545"
    default_start_block = 0
    confirmation_block_count = 0
    syncInterval = 10
    portal_addr = "0x1212400000000000000000000000000000000001"
  }
  external_chains_staging = [
    {
      chain_name = "chain-a"
      rpc_addr = "http://staging.omni.network:6545"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0x7965Bb94fD6129B4Ac9028243BeFA0fACe1d7286"
    },
    {
      chain_name = "chain-b"
      rpc_addr = "http://staging.omni.network:7545"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0x7965Bb94fD6129B4Ac9028243BeFA0fACe1d7286"
    }
  ]
  xchain_indexer_staging_docker_image = "omniops/xchain-indexer:0.1.2"
  blockscout_staging_docker_image = "omniops/blockscout:0.1.0.commit.2404d446"

  omni_testnet_ws = "ws://testnet-sentry-explorer.omni.network:8546"
  omni_chain_config_testnet = {
    rpc_addr = "http://testnet-sentry-explorer.omni.network:8545"
    default_start_block = 0
    confirmation_block_count = 0
    syncInterval = 10
    portal_addr = "0x1212400000000000000000000000000000000001"
  }
  external_chains_testnet = [
    {
      chain_name = "optimism-goerli"
      rpc_addr = "https://optimism-goerli.infura.io/v3/1e8b7c7931d24be095e34d0177c14854"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0xcbbc5Da52ea2728279560Dca8f4ec08d5F829985"
    },
    {
      chain_name = "arbitrum-goerli"
      rpc_addr = "https://arbitrum-goerli.infura.io/v3/1e8b7c7931d24be095e34d0177c14854"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0xcbbc5Da52ea2728279560Dca8f4ec08d5F829985"
    },
    {
      chain_name = "linea-goerli"
      rpc_addr = "https://linea-goerli.infura.io/v3/1e8b7c7931d24be095e34d0177c14854"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0xcbbc5Da52ea2728279560Dca8f4ec08d5F829985"
    },
    {
      chain_name = "scroll-sepolia"
      rpc_addr = "http://archive-node.sepolia.scroll.xyz:8545"
      default_start_block = -1
      confirmation_block_count = 10
      syncInterval = 30
      portal_addr = "0xcbbc5Da52ea2728279560Dca8f4ec08d5F829985"
    }
  ]
  xchain_indexer_testnet_docker_image = "omniops/xchain-indexer:latest"
  blockscout_testnet_docker_image = "omniops/blockscout:0.1.0.commit.2404d446"
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
    enabled             = true
    docker_image        = local.xchain_indexer_staging_docker_image
    config_file_content = jsonencode({
      omni_config = local.omni_chain_config_staging,
      external_chains = [
        for x_chain in local.external_chains_staging : x_chain
      ]
    })
  }
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_staging_docker_image
    rpc_address             = local.omni_chain_config_staging.rpc_addr
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
    enabled             = true
    docker_image        = local.xchain_indexer_testnet_docker_image
    config_file_content = jsonencode({
      omni_config = local.omni_chain_config_testnet,
      external_chains = [
        for x_chain in local.external_chains_testnet : x_chain
      ]
    })
  }
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_testnet_docker_image
    rpc_address             = local.omni_chain_config_testnet.rpc_addr
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
