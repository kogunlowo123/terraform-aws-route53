output "public_zone_ids" {
  description = "Map of public hosted zone names to zone IDs."
  value       = { for k, v in aws_route53_zone.public : k => v.zone_id }
}

output "public_zone_arns" {
  description = "Map of public hosted zone names to ARNs."
  value       = { for k, v in aws_route53_zone.public : k => v.arn }
}

output "public_zone_name_servers" {
  description = "Map of public hosted zone names to name servers."
  value       = { for k, v in aws_route53_zone.public : k => v.name_servers }
}

output "private_zone_ids" {
  description = "Map of private hosted zone names to zone IDs."
  value       = { for k, v in aws_route53_zone.private : k => v.zone_id }
}

output "private_zone_arns" {
  description = "Map of private hosted zone names to ARNs."
  value       = { for k, v in aws_route53_zone.private : k => v.arn }
}

output "record_fqdns" {
  description = "Map of record keys to FQDNs."
  value = merge(
    { for k, v in aws_route53_record.simple : k => v.fqdn },
    { for k, v in aws_route53_record.alias : k => v.fqdn },
  )
}

output "health_check_ids" {
  description = "Map of health check names to IDs."
  value       = { for k, v in aws_route53_health_check.this : k => v.id }
}

output "health_check_arns" {
  description = "Map of health check names to ARNs."
  value       = { for k, v in aws_route53_health_check.this : k => v.arn }
}

output "resolver_endpoint_ids" {
  description = "Map of resolver endpoint names to IDs."
  value       = { for k, v in aws_route53_resolver_endpoint.this : k => v.id }
}

output "resolver_endpoint_arns" {
  description = "Map of resolver endpoint names to ARNs."
  value       = { for k, v in aws_route53_resolver_endpoint.this : k => v.arn }
}

output "resolver_endpoint_ips" {
  description = "Map of resolver endpoint names to IP addresses."
  value       = { for k, v in aws_route53_resolver_endpoint.this : k => v.ip_address }
}

output "resolver_rule_ids" {
  description = "Map of resolver rule names to IDs."
  value       = { for k, v in aws_route53_resolver_rule.this : k => v.id }
}

output "resolver_rule_arns" {
  description = "Map of resolver rule names to ARNs."
  value       = { for k, v in aws_route53_resolver_rule.this : k => v.arn }
}

output "zone_ids" {
  description = "Merged map of all zone names to zone IDs."
  value = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )
}
