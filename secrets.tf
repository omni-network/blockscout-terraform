variable "infura_api_key" {
    description = "Infura api key used for talking to external chains"
    type = string
    sensitive = true
}

variable "testnet_sentry_node_url" {
    description = "URL of the testnet sentry node"
    type = string
    sensitive = true
}
