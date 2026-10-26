output "resource_group_name" {
  description = "Name of the application resource group"
  value       = azurerm_resource_group.app.name
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault"
  value       = azurerm_key_vault.app.name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault"
  value       = azurerm_key_vault.app.vault_uri
}

output "spoke_vnet_name" {
  description = "Existing spoke VNet used by the PaaS workload"
  value       = data.azurerm_virtual_network.spoke.name
}

output "private_endpoint_subnet_id" {
  description = "Subnet used for private endpoints"
  value       = data.azurerm_subnet.private_endpoints.id
}

output "sql_server_name" {
  description = "Azure SQL logical server name"
  value       = azurerm_mssql_server.app.name
}

output "sql_database_name" {
  description = "Azure SQL database name"
  value       = azurerm_mssql_database.app.name
}

output "sql_server_fqdn" {
  description = "Azure SQL Server fully qualified domain name"
  value       = azurerm_mssql_server.app.fully_qualified_domain_name
}

output "sql_private_endpoint_ip" {
  description = "Private IP assigned to the SQL private endpoint"
  value       = azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address
}
output "sql_server_fqdn_secret_name" {
  description = "Name of the Key Vault secret containing the SQL Server FQDN"
  value       = azurerm_key_vault_secret.sql_server_fqdn.name
}
output "app_identity_name" {
  description = "Name of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.app.name
}

output "app_identity_client_id" {
  description = "Client ID of the application managed identity"
  value       = azurerm_user_assigned_identity.app.client_id
}

output "app_identity_principal_id" {
  description = "Principal ID of the application managed identity"
  value       = azurerm_user_assigned_identity.app.principal_id
}
output "sql_database_secret_name" {
  description = "Key Vault secret containing the SQL database name"
  value       = azurerm_key_vault_secret.sql_database_name.name
}

output "sql_connection_string_secret_name" {
  description = "Key Vault secret containing the managed identity SQL connection string"
  value       = azurerm_key_vault_secret.sql_connection_string.name
}