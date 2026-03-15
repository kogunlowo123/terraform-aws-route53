module "test" {
  source = "../"

  name = "test-dns"

  tags = {
    Project     = "route53-test"
    Environment = "test"
  }

  # Public Hosted Zones
  public_zones = {
    "example.com" = {
      comment       = "Test public hosted zone"
      force_destroy = true
    }
  }

  # DNS Records
  records = {
    "www" = {
      zone_key = "example.com"
      name     = "www.example.com"
      type     = "A"
      ttl      = 300
      records  = ["10.0.0.1"]
    }
    "mail" = {
      zone_key = "example.com"
      name     = "example.com"
      type     = "MX"
      ttl      = 300
      records  = ["10 mail.example.com"]
    }
  }

  # Health Checks
  health_checks = {
    "www-check" = {
      type              = "HTTPS"
      fqdn              = "www.example.com"
      port              = 443
      resource_path     = "/health"
      failure_threshold = 3
      request_interval  = 30
    }
  }
}
