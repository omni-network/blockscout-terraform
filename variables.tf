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
  default     = false
}
