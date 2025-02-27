variable "name" {
  type = string
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "vpc_zone_identifier" {
  type = list(any)
}
variable "launch_template_name" {
  type = string
}
variable "image_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "create_iam_instance_profile" {
  type = bool
}
variable "iam_instance_profile_arn" {
  type = string
}
variable "iam_role_name" {
  type = string
}
variable "docker_compose_config" {
  type = any
}
variable "xchain_config_file_content" {
  type = string
  default = ""
}
variable "agent_secret_file_content" {
  description = "Grafana Agent secrets file content"
  type        = string
  sensitive   = true
}

variable "agent_env" {
  description = "Grafana Agent env label"
  type = string
}
variable "path_docker_compose_files" {
  type = string
}
variable "user" {
  type = string
}
variable "security_groups" {
  type = string
}
variable "tags" {
  type = any
}
variable "target_group_arns" {
  type = list(any)
}
variable "block_devices" {
  type = list(any)
}
variable "docker_compose_file_postfix" {
  type    = string
  default = ""
}
