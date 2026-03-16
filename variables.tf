variable "name" {
  description = "Name prefix for resources."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "public_zones" {
  description = "Map of public hosted zones to create."
  type = map(object({
    comment       = optional(string, "")
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "private_zones" {
  description = "Map of private hosted zones to create."
  type = map(object({
    comment       = optional(string, "")
    vpc_ids       = list(string)
    vpc_region    = optional(string, "")
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "records" {
  description = "Map of DNS records to create."
  type = map(object({
    zone_key = string
    name     = string
    type     = string
    ttl      = optional(number, 300)
    records  = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }))
    set_identifier = optional(string)
    weighted = optional(object({
      weight = number
    }))
    latency = optional(object({
      region = string
    }))
    failover = optional(object({
      type = string
    }))
    geolocation = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    health_check_id = optional(string)
  }))
  default = {}
}

variable "health_checks" {
  description = "Map of Route53 health checks to create."
  type = map(object({
    type                            = optional(string, "HTTPS")
    fqdn                            = optional(string)
    ip_address                      = optional(string)
    port                            = optional(number, 443)
    resource_path                   = optional(string, "/")
    failure_threshold               = optional(number, 3)
    request_interval                = optional(number, 30)
    search_string                   = optional(string)
    measure_latency                 = optional(bool, false)
    invert_healthcheck              = optional(bool, false)
    enable_sni                      = optional(bool, true)
    regions                         = optional(list(string))
    insufficient_data_health_status = optional(string)
    disabled                        = optional(bool, false)
    child_health_checks             = optional(list(string))
    child_healthcheck_threshold     = optional(number)
    cloudwatch_alarm_name           = optional(string)
    cloudwatch_alarm_region         = optional(string)
    tags                            = optional(map(string), {})
  }))
  default = {}
}

variable "enable_dnssec" {
  description = "Map of zone keys to enable DNSSEC signing."
  type        = map(bool)
  default     = {}
}

variable "dnssec_kms_key_arns" {
  description = "Map of zone keys to KMS key ARNs for DNSSEC."
  type        = map(string)
  default     = {}
}

variable "query_logging" {
  description = "Map of zone keys to enable query logging."
  type = map(object({
    cloudwatch_log_group_arn = string
  }))
  default = {}
}

variable "resolver_endpoints" {
  description = "Map of Route53 Resolver endpoints to create."
  type = map(object({
    direction          = string
    security_group_ids = list(string)
    ip_addresses = list(object({
      subnet_id = string
      ip        = optional(string)
    }))
    protocols = optional(list(string), ["Do53"])
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "resolver_rules" {
  description = "Map of Route53 Resolver rules to create."
  type = map(object({
    domain_name          = string
    rule_type            = optional(string, "FORWARD")
    resolver_endpoint_id = optional(string)
    endpoint_key         = optional(string)
    target_ips = optional(list(object({
      ip   = string
      port = optional(number, 53)
    })), [])
    vpc_ids = optional(list(string), [])
    tags    = optional(map(string), {})
  }))
  default = {}
}
