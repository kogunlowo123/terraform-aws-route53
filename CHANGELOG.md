# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Initial release of terraform-aws-route53 module
- Public hosted zone management
- Private hosted zone management with VPC associations
- DNS record creation (simple and alias)
- Weighted routing policy support
- Latency-based routing policy support
- Failover routing policy support
- Geolocation routing policy support
- Health checks (HTTP, HTTPS, TCP, calculated, CloudWatch)
- DNSSEC signing with KMS key support
- DNS query logging to CloudWatch
- Route53 Resolver inbound and outbound endpoints
- Resolver forwarding rules with VPC associations
- Basic and complete usage examples
