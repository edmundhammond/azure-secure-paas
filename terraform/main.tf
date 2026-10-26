data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-dev"
  resource_group_name = "rg-landingzone-dev"
}

data "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = "rg-landingzone-dev"
}

resource "azurerm_resource_group" "app" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_key_vault" "app" {
  name = "kv-${var.project_name}-${var.environment}-${random_string.suffix.result}"

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled    = true
  public_network_access_enabled = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.app.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name = "link-securepaas-sql"

  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = data.azurerm_virtual_network.spoke.id

  registration_enabled = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_mssql_server" "app" {
  name = "sql-${var.project_name}-${var.environment}-${random_string.suffix.result}"

  resource_group_name = azurerm_resource_group.app.name
  location            = var.sql_location

  version = "12.0"

  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = "AzureAD Admin"
    object_id                   = data.azurerm_client_config.current.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_mssql_database" "app" {
  name      = "sqldb-${var.project_name}-${var.environment}"
  server_id = azurerm_mssql_server.app.id

  sku_name    = "Basic"
  max_size_gb = 2

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_endpoint" "sql" {
  name = "pe-sql-${var.project_name}-${var.environment}"

  resource_group_name = azurerm_resource_group.app.name
  location            = data.azurerm_virtual_network.spoke.location
  subnet_id           = data.azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-sql-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.app.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "sql-private-dns"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.sql.id
    ]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_role_assignment" "current_user_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.app.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "sql_server_fqdn" {
  name         = "sql-server-fqdn"
  value        = azurerm_mssql_server.app.fully_qualified_domain_name
  key_vault_id = azurerm_key_vault.app.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_secrets_officer
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.app.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name = "link-securepaas-keyvault"

  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = data.azurerm_virtual_network.spoke.id

  registration_enabled = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name = "pe-kv-${var.project_name}-${var.environment}"

  resource_group_name = azurerm_resource_group.app.name
  location            = data.azurerm_virtual_network.spoke.location
  subnet_id           = data.azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-kv-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_key_vault.app.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "keyvault-private-dns"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_role_assignment" "app_key_vault_secrets_user" {
  scope                = azurerm_key_vault.app.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
resource "azurerm_key_vault_secret" "sql_database_name" {
  name         = "sql-database-name"
  value        = azurerm_mssql_database.app.name
  key_vault_id = azurerm_key_vault.app.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_secrets_officer
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name = "sql-connection-string"

  value = "Server=tcp:${azurerm_mssql_server.app.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.app.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;"

  key_vault_id = azurerm_key_vault.app.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_secrets_officer
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "SecureAzurePaaS"
  }
}