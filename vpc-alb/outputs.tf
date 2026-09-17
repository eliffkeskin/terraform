output "url" {
  description = "URL"
  value       = "http://${module.web.alb_dns_name}"
}