variable "project" {
  description = "GCP project id where resources will be deployed"
  type        = string
}

variable "region" {
  description = "Location to deploy Cloud Run resources"
  type        = string
}

variable "create_kms_keyring_and_key" {
  description = <<-EOF
    To enable auto unseal for Vault, a Kms key ring and encryption key is created. Terraform can not destroy Kms keys or key rings
    instead they are removed from the state. If this module has already been run once and the key ring already exists in the project
    set this vaule to false to avoid errors.
  EOF
  type        = bool
  default     = true
}

variable "admin_service_accounts" {
  description = "The email addresses for the service accounts allowed to login to Vault and that are allocated admin rights"
  type        = list(string)
}

variable "additional_admin_policy" {
  description = "Additional admin policy granted to admin_service_accounts"
  type        = string
  default     = ""
}

variable "cpu" {
  description = "Number of CPUs to allocate the Cloud Run instance"
  type        = string
  default     = "2.0"
}

variable "memory" {
  description = "Amount of Memory to allocate the Cloud Run instance"
  type        = string
  default     = "2048Mi"
}
