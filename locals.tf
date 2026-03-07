locals {
  # Merge all zone IDs for easy lookup
  zone_ids = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )

  # Filter records by type
  alias_records  = { for k, v in var.records : k => v if v.alias != null }
  simple_records = { for k, v in var.records : k => v if v.alias == null }

  common_tags = merge(var.tags, {
    Module    = "terraform-aws-route53"
    ManagedBy = "terraform"
  })
}
