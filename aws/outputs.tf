output "blockscout_url" {
  description = "DNS name of frontend"
  value       = module.alb.lb_dns_name
}

output "xchain_url" {
  description = "DNS name of xchain api"
  value       = var.xchain_settings["enabled"] ? module.alb_xchain[0].lb_dns_name : ""
}