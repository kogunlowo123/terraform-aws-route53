provider "aws" {
  region = "us-east-1"
}

module "route53" {
  source = "../../"

  name = "prod-dns"

  # Public and private zones
  public_zones = {
    "example.com" = {
      comment = "Production public zone"
    }
    "api.example.com" = {
      comment = "API subdomain zone"
    }
  }

  private_zones = {
    "internal.example.com" = {
      comment = "Internal services"
      vpc_ids = ["vpc-0123456789abcdef0"]
    }
  }

  # Health checks
  health_checks = {
    primary-web = {
      type              = "HTTPS"
      fqdn              = "www.example.com"
      port              = 443
      resource_path     = "/health"
      failure_threshold = 3
      request_interval  = 30
      measure_latency   = true
    }
    secondary-web = {
      type              = "HTTPS"
      fqdn              = "www-dr.example.com"
      port              = 443
      resource_path     = "/health"
      failure_threshold = 3
      request_interval  = 30
    }
  }

  # DNS records with routing policies
  records = {
    # Simple record
    www = {
      zone_key = "example.com"
      name     = "www.example.com"
      type     = "A"
      ttl      = 60
      records  = ["10.0.1.100"]
    }

    # Weighted routing
    api-us = {
      zone_key       = "example.com"
      name           = "api.example.com"
      type           = "A"
      ttl            = 60
      records        = ["10.0.1.200"]
      set_identifier = "us-east"
      weighted       = { weight = 70 }
    }
    api-eu = {
      zone_key       = "example.com"
      name           = "api.example.com"
      type           = "A"
      ttl            = 60
      records        = ["10.0.2.200"]
      set_identifier = "eu-west"
      weighted       = { weight = 30 }
    }

    # Failover routing
    db-primary = {
      zone_key       = "example.com"
      name           = "db.example.com"
      type           = "CNAME"
      ttl            = 60
      records        = ["primary-db.example.com"]
      set_identifier = "primary"
      failover       = { type = "PRIMARY" }
    }
    db-secondary = {
      zone_key       = "example.com"
      name           = "db.example.com"
      type           = "CNAME"
      ttl            = 60
      records        = ["replica-db.example.com"]
      set_identifier = "secondary"
      failover       = { type = "SECONDARY" }
    }

    # Geolocation routing
    cdn-us = {
      zone_key       = "example.com"
      name           = "cdn.example.com"
      type           = "CNAME"
      ttl            = 300
      records        = ["us.cdn.example.com"]
      set_identifier = "us"
      geolocation    = { country = "US" }
    }
    cdn-eu = {
      zone_key       = "example.com"
      name           = "cdn.example.com"
      type           = "CNAME"
      ttl            = 300
      records        = ["eu.cdn.example.com"]
      set_identifier = "eu"
      geolocation    = { continent = "EU" }
    }
    cdn-default = {
      zone_key       = "example.com"
      name           = "cdn.example.com"
      type           = "CNAME"
      ttl            = 300
      records        = ["global.cdn.example.com"]
      set_identifier = "default"
      geolocation    = { country = "*" }
    }

    # Alias record
    root-alias = {
      zone_key = "example.com"
      name     = "example.com"
      type     = "A"
      alias = {
        name                   = "d111111abcdef8.cloudfront.net"
        zone_id                = "Z2FDTNDATAQYW2"
        evaluate_target_health = false
      }
    }

    # Private zone record
    internal-api = {
      zone_key = "internal.example.com"
      name     = "api.internal.example.com"
      type     = "A"
      ttl      = 60
      records  = ["10.0.10.50"]
    }
  }

  # Query logging
  query_logging = {
    "example.com" = {
      cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/example.com"
    }
  }

  # Resolver endpoints
  resolver_endpoints = {
    inbound = {
      direction          = "INBOUND"
      security_group_ids = ["sg-0123456789abcdef0"]
      ip_addresses = [
        { subnet_id = "subnet-0123456789abcdef0" },
        { subnet_id = "subnet-0123456789abcdef1" },
      ]
    }
    outbound = {
      direction          = "OUTBOUND"
      security_group_ids = ["sg-0123456789abcdef0"]
      ip_addresses = [
        { subnet_id = "subnet-0123456789abcdef0" },
        { subnet_id = "subnet-0123456789abcdef1" },
      ]
    }
  }

  resolver_rules = {
    on-prem = {
      domain_name  = "corp.example.com"
      rule_type    = "FORWARD"
      endpoint_key = "outbound"
      target_ips = [
        { ip = "10.100.1.1", port = 53 },
        { ip = "10.100.1.2", port = 53 },
      ]
      vpc_ids = ["vpc-0123456789abcdef0"]
    }
  }

  tags = {
    Environment = "production"
    Project     = "dns-management"
  }
}
