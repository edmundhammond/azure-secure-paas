variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "eastus"
}

variable "sql_location" {
  description = "Azure region used for Azure SQL"
  type        = string
  default     = "centralus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "securepaas"
}
variable "secret_expiration_date" {
  description = "Expiration date for Key Vault application configuration secrets"
  type        = string
  default     = "2027-10-26T00:00:00Z"
}