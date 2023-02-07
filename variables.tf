variable "project_id" {
  default     = "cloud-security-day-1060272596826"
  description = "Project ID in GCP"
}

variable "region" {
  default     = "cloud-security-day"
  description = "Region to deploy GCP resources"
}

variable "service_account_email" {
  description = "The email address for the service account allowed to administer Vault"
}
