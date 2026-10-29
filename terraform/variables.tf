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
variable "admin_object_id" {
  description = "Microsoft Entra object ID of the human administrator"
  type        = string
  default     = "4c064d64-565c-443a-8c4b-44ebaa419f7b"
}