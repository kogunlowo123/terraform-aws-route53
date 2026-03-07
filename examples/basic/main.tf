provider "aws" {
  region = "us-east-1"
}

module "route53" {
  source = "../../"

  name = "my-dns"

  public_zones = {
    "example.com" = {
      comment = "Primary domain"
    }
  }

  records = {
    www = {
      zone_key = "example.com"
      name     = "www.example.com"
      type     = "A"
      ttl      = 300
      records  = ["10.0.1.100"]
    }
    mail = {
      zone_key = "example.com"
      name     = "example.com"
      type     = "MX"
      ttl      = 300
      records  = ["10 mail.example.com"]
    }
  }

  tags = {
    Environment = "dev"
  }
}

output "zone_ids" {
  value = module.route53.public_zone_ids
}

output "name_servers" {
  value = module.route53.public_zone_name_servers
}
