################################################################################
# Public Hosted Zones
################################################################################

resource "aws_route53_zone" "public" {
  for_each = var.public_zones

  name          = each.key
  comment       = each.value.comment
  force_destroy = each.value.force_destroy

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Private Hosted Zones
################################################################################

resource "aws_route53_zone" "private" {
  for_each = var.private_zones

  name          = each.key
  comment       = each.value.comment
  force_destroy = each.value.force_destroy

  dynamic "vpc" {
    for_each = each.value.vpc_ids

    content {
      vpc_id     = vpc.value
      vpc_region = each.value.vpc_region != "" ? each.value.vpc_region : null
    }
  }

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Simple DNS Records
################################################################################

resource "aws_route53_record" "simple" {
  for_each = { for k, v in var.records : k => v if v.alias == null }

  zone_id = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )[each.value.zone_key]
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records

  set_identifier = each.value.set_identifier

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted != null ? [each.value.weighted] : []

    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency != null ? [each.value.latency] : []

    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover != null ? [each.value.failover] : []

    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation != null ? [each.value.geolocation] : []

    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  health_check_id = each.value.health_check_id
}

################################################################################
# Alias DNS Records
################################################################################

resource "aws_route53_record" "alias" {
  for_each = { for k, v in var.records : k => v if v.alias != null }

  zone_id = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )[each.value.zone_key]
  name = each.value.name
  type = each.value.type

  set_identifier = each.value.set_identifier

  alias {
    name                   = each.value.alias.name
    zone_id                = each.value.alias.zone_id
    evaluate_target_health = each.value.alias.evaluate_target_health
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted != null ? [each.value.weighted] : []

    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency != null ? [each.value.latency] : []

    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover != null ? [each.value.failover] : []

    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation != null ? [each.value.geolocation] : []

    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  health_check_id = each.value.health_check_id
}

################################################################################
# Health Checks
################################################################################

resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  type                            = each.value.type
  fqdn                            = each.value.fqdn
  ip_address                      = each.value.ip_address
  port                            = each.value.port
  resource_path                   = each.value.resource_path
  failure_threshold               = each.value.failure_threshold
  request_interval                = each.value.request_interval
  search_string                   = each.value.search_string
  measure_latency                 = each.value.measure_latency
  invert_healthcheck              = each.value.invert_healthcheck
  enable_sni                      = each.value.enable_sni
  regions                         = each.value.regions
  insufficient_data_health_status = each.value.insufficient_data_health_status
  disabled                        = each.value.disabled

  child_health_checks         = each.value.child_health_checks
  child_healthcheck_threshold = each.value.child_healthcheck_threshold

  cloudwatch_alarm_name   = each.value.cloudwatch_alarm_name
  cloudwatch_alarm_region = each.value.cloudwatch_alarm_region

  tags = merge(var.tags, { Name = each.key }, each.value.tags)
}

################################################################################
# DNSSEC
################################################################################

resource "aws_route53_key_signing_key" "this" {
  for_each = var.enable_dnssec

  hosted_zone_id = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )[each.key]
  key_management_service_arn = var.dnssec_kms_key_arns[each.key]
  name                       = "${each.key}-ksk"
}

resource "aws_route53_hosted_zone_dnssec" "this" {
  for_each = var.enable_dnssec

  hosted_zone_id = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )[each.key]

  depends_on = [aws_route53_key_signing_key.this]
}

################################################################################
# Query Logging
################################################################################

resource "aws_route53_query_log" "this" {
  for_each = var.query_logging

  zone_id = merge(
    { for k, v in aws_route53_zone.public : k => v.zone_id },
    { for k, v in aws_route53_zone.private : k => v.zone_id },
  )[each.key]
  cloudwatch_log_group_arn = each.value.cloudwatch_log_group_arn
}

################################################################################
# Resolver Endpoints
################################################################################

resource "aws_route53_resolver_endpoint" "this" {
  for_each = var.resolver_endpoints

  name      = "${var.name}-${each.key}"
  direction = each.value.direction

  security_group_ids = each.value.security_group_ids
  protocols          = each.value.protocols

  dynamic "ip_address" {
    for_each = each.value.ip_addresses

    content {
      subnet_id = ip_address.value.subnet_id
      ip        = ip_address.value.ip
    }
  }

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Resolver Rules
################################################################################

resource "aws_route53_resolver_rule" "this" {
  for_each = var.resolver_rules

  name                 = "${var.name}-${each.key}"
  domain_name          = each.value.domain_name
  rule_type            = each.value.rule_type
  resolver_endpoint_id = each.value.endpoint_key != null ? aws_route53_resolver_endpoint.this[each.value.endpoint_key].id : each.value.resolver_endpoint_id

  dynamic "target_ip" {
    for_each = each.value.target_ips

    content {
      ip   = target_ip.value.ip
      port = target_ip.value.port
    }
  }

  tags = merge(var.tags, each.value.tags)
}

resource "aws_route53_resolver_rule_association" "this" {
  for_each = { for pair in flatten([
    for rk, rv in var.resolver_rules : [
      for vpc_id in rv.vpc_ids : {
        key      = "${rk}-${vpc_id}"
        rule_key = rk
        vpc_id   = vpc_id
      }
    ]
  ]) : pair.key => pair }

  resolver_rule_id = aws_route53_resolver_rule.this[each.value.rule_key].id
  vpc_id           = each.value.vpc_id
}
