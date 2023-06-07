variable "ssl_certificate_arn" {
  description = "The ARN of the SSL Certificate for the load balancer. Find in AWS Certificate Manager."
  type        = string
}

variable "deploy_internal_blockscout" {
  description = "Whether to deploy the internal blockscout service."
  type        = bool
  default     = true
}
