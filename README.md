# terraform-aws-route53

Terraform module for managing AWS Route53 hosted zones, DNS records, health checks, routing policies, DNSSEC, query logging, and resolver endpoints.

## Architecture

```mermaid
flowchart TD
    A[Route53] --> B[Public Hosted Zones]
    A --> C[Private Hosted Zones]
    A --> D[Health Checks]
    A --> E[Resolver Endpoints]

    B --> F[DNS Records]
    C --> F

    F --> G{Routing Policy}
    G -->|Simple| H[Direct Response]
    G -->|Weighted| I[Traffic Distribution]
    G -->|Latency| J[Nearest Region]
    G -->|Failover| K[Primary / Secondary]
    G -->|Geolocation| L[Geographic Routing]

    D --> D1[HTTP/HTTPS Checks]
    D --> D2[TCP Checks]
    D --> D3[Calculated Checks]
    D --> D4[CloudWatch Alarm Checks]

    K --> D

    A --> M[DNSSEC]
    M --> N[KMS Signing Key]

    A --> O[Query Logging]
    O --> P[CloudWatch Logs]

    E --> E1[Inbound Endpoint]
    E --> E2[Outbound Endpoint]
    E2 --> Q[Resolver Rules]
    Q --> R[On-Premises DNS]

    C --> S[VPC Association]

    style A fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
    style B fill:#3498DB,stroke:#2980B9,color:#FFFFFF
    style C fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style D fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style E fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style F fill:#F39C12,stroke:#E67E22,color:#FFFFFF
    style G fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
    style H fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style I fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style J fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style K fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style L fill:#85C1E9,stroke:#3498DB,color:#FFFFFF
    style D1 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style D2 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style D3 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style D4 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style M fill:#F1C40F,stroke:#F39C12,color:#333333
    style N fill:#F1C40F,stroke:#F39C12,color:#333333
    style O fill:#AF7AC5,stroke:#8E44AD,color:#FFFFFF
    style P fill:#AF7AC5,stroke:#8E44AD,color:#FFFFFF
    style E1 fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style E2 fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style Q fill:#D2B4DE,stroke:#8E44AD,color:#333333
    style R fill:#AEB6BF,stroke:#7F8C8D,color:#FFFFFF
    style S fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
```

## Features

- **Public Hosted Zones** - Internet-facing DNS zones
- **Private Hosted Zones** - VPC-scoped DNS zones with VPC associations
- **DNS Records** - A, AAAA, CNAME, MX, TXT, SRV, and alias records
- **Routing Policies** - Weighted, latency-based, failover, and geolocation routing
- **Health Checks** - HTTP, HTTPS, TCP, calculated, and CloudWatch alarm checks
- **DNSSEC** - Zone signing with KMS-managed keys
- **Query Logging** - DNS query logs to CloudWatch
- **Resolver Endpoints** - Inbound and outbound DNS resolvers for hybrid environments
- **Resolver Rules** - Conditional forwarding rules with VPC associations

## Usage

```hcl
module "route53" {
  source = "path/to/terraform-aws-route53"

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
      records  = ["10.0.1.100"]
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [Basic](examples/basic/) - Public zone with simple records
- [Complete](examples/complete/) - Full setup with routing policies, health checks, and resolvers

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5.0 |
| aws       | >= 5.0   |

## License

MIT License - see [LICENSE](LICENSE) for details.
