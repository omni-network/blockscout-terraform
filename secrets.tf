variable "infura_api_key" {
    description = "Infura api key used for talking to external chains"
    type        = string
    sensitive   = true
}

variable "testnet_sentry_node_url" {
    description = "URL of the testnet sentry node"
    type        = string
    sensitive   = true
}

variable "cloudflare_api_token" {
    description = "The Cloudflare API token."
    type        = string
    sensitive   = true
}

variable "prometheus_url" {
    description = "The Prometheus URL."
    type        = string
    sensitive   = true
}

variable "prometheus_user" {
    description = "The Prometheus user."
    type        = string
    sensitive   = true
}

variable "prometheus_password" {
    description = "The Prometheus password."
    type        = string
    sensitive   = true
}

variable "loki_host" {
    description = "The Loki host."
    type        = string
    sensitive   = true
}

variable "loki_user" {
    description = "The Loki user."
    type        = string
    sensitive   = true
}

variable "loki_password" {
    description = "The Loki password."
    type        = string
    sensitive   = true
}

