variable "cloudflare_api_token" {
  description = "The Cloudflare API token."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID."
  type        = string
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL Certificate for the load balancer. Find in AWS Certificate Manager."
  type        = string
}

variable "deploy_staging_blockscout" {
  description = "Whether to deploy the staging blockscout service."
  type        = bool
  default     = true
}

variable "deploy_testnet_blockscout" {
  description = "Whether to deploy the testnet blockscout service."
  type        = bool
  default     = true
}

variable "staging_blockscout_docker_image" {
  description = "The staging blockscout docker image."
  type        = string
  default     = "omniops/blockscout:latest"
}

variable "testnet_blockscout_docker_image" {
  description = "The testnet blockscout docker image."
  type        = string
  default     = "omniops/blockscout:latest"
}

variable "xchain_indexer_docker_image" {
  description = "The xchain indexer docker image."
  type        = string
  default     = "omniops/xchain-indexer:latest"
}

variable "staging_xchain_indexer_omni_config_rpc_addr" {
  description = "The rpc address used by the omni indexer on staging."
  type        = string
  default     = "http://staging.omni.network:8545"
}
