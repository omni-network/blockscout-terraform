locals {
  blockscout_docker_image = "omniops/blockscout:5.1.5-omnibeta.1"
}

provider "aws" {
  region = "us-east-1"
}


module "obs_internal_vpc" {
  source                                 = "./aws"
  count                                  = var.deploy_internal_blockscout ? 1 : 0
  vpc_name                               = "obs-internal"
  vpc_cidr                               = "10.104.0.0/16"
  ssl_certificate_arn                    = var.ssl_certificate_arn
  create_iam_instance_profile_ssm_policy = "true"
  deploy_ec2_instance_db                 = false
  deploy_rds_db                          = true
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_docker_image
    rpc_address             = "http://internal-testnet-rpc.omni.network:8545"
    ws_address              = "ws://internal-testnet-rpc.omni.network:8546"
    chain_id                = "165"
  }
  tags = {
    project           = "omni-internal-blockscout"
    terraform_managed = true
  }
}

module "obs_testnet_vpc" {
  source                                 = "./aws"
  vpc_name                               = "obs-testnet"
  vpc_cidr                               = "10.105.0.0/16"
  ssl_certificate_arn                    = var.ssl_certificate_arn
  create_iam_instance_profile_ssm_policy = "true"
  deploy_ec2_instance_db                 = false
  deploy_rds_db                          = true
  blockscout_settings = {
    blockscout_docker_image = local.blockscout_docker_image
    rpc_address             = "http://testnet-1-rpc.omni.network:8545"
    ws_address              = "ws://testnet-1-rpc.omni.network:8546"
    chain_id                = "165"
  }
  tags = {
    project           = "omni-testnet-blockscout"
    terraform_managed = true
  }
}

output "internal_blockscout_url" {
  value = var.deploy_internal_blockscout ? module.obs_internal_vpc[0].blockscout_url : null
}

output "testnet_blockscout_url" {
  value = module.obs_testnet_vpc.blockscout_url
}
