# Azure Secure PaaS Infrastructure

Security-focused Azure PaaS infrastructure built with Terraform and integrated with an existing Azure landing zone.

## Architecture

```text
GitHub Actions
      |
      | OIDC
      v
Azure
├── Azure SQL Database
├── Azure Key Vault
├── User-Assigned Managed Identity
├── Private Endpoints
├── Private DNS
└── Existing Spoke VNet
```

## Key Features

- Terraform-based Azure infrastructure
- Azure SQL with public network access disabled
- Microsoft Entra ID authentication
- Azure Key Vault with RBAC
- User-assigned managed identity
- Private endpoints for SQL and Key Vault
- Private DNS integration
- Remote Terraform state in Azure Storage
- GitHub Actions CI
- Passwordless Azure authentication using OIDC
- Checkov security scanning

## CI Pipeline

```text
terraform fmt
      ↓
terraform validate
      ↓
Checkov
      ↓
Azure OIDC Login
      ↓
Remote Backend Init
      ↓
terraform plan
```

Final Checkov result:

```text
Passed: 15
Failed: 0
Skipped: 7
```

Skipped controls are documented development-lab exceptions, including advanced SQL auditing, zone redundancy, and temporary Key Vault public access.

## Security Design

Azure SQL uses private connectivity and Entra-only authentication.

Application configuration is stored in Key Vault, including the SQL server name, database name, and a managed-identity connection string.

The application identity receives only the Key Vault permissions required to read secrets.

## App Service Note

Azure App Service was part of the original design but could not be deployed because the lab subscription currently has zero available App Service Plan quota.

The project was therefore completed as the secure PaaS infrastructure foundation. App Service can be added later without redesigning the networking, identity, SQL, Key Vault, or CI architecture.

## Technologies

Terraform · Azure SQL · Azure Key Vault · Managed Identity · Private Link · Private DNS · Azure RBAC · Microsoft Entra ID · GitHub Actions · OIDC · Checkov

## Status

**Complete**

Core infrastructure, security controls, private networking, remote state, OIDC authentication, and Terraform CI validation are implemented and working.