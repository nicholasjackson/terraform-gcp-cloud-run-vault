variable "project" {
  description = "GCP project id where resources will be deployed"
  type        = string
}

variable "region" {
  description = "Location to deploy Cloud Run resources"
  type        = string
}

variable "create_kms_keyring" {
  description = <<-EOF
    To enable auto unseal for Vault, a Kms key ring and encryption key is created. Terraform can not destroy Kms keys or key rings
    instead they are removed from the state. If this module has already been run once and the key ring already exists in the project
    set this vaule to false to avoid errors.
  EOF
  type        = bool
  default     = true
}

variable "kms_keyring_name" {
  type        = string
  description = "Name of the KMS Keyring to use for auto unseal. If create_kms_keyring is set to true, this will be the name of the keyring created."
  default     = "vault-unseal"
}

variable "kms_crypto_key_prefix" {
  description = "Prefix for the KMS Key to use for auto unseal. Unique named keys are always created as GCP does not immedately remove a key on destroy."
  type        = string
  default     = "unseal"
}

variable "admin_service_accounts" {
  description = "The email addresses for the service accounts allowed to login to Vault and that are allocated admin rights"
  type        = list(string)
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

variable "recovery_pgp_keys" {
  description = <<-EOF
    PGP keys used to encrypt the Vault recovery keys. The number of keys specified
    corresponds to the number of recovery keys generated. Recovery keys allow the generation
    of root tokens and should be protected. To ensure that no one individual can generate a root
    token or rekey Vault, multiple recovery_pgp_keys should be specified. You can set recovery_threshold
    to determine how many keys are needed to generate a root token or to rekey Vault. A general
    setup for this would be to specify 5 recovery keys, but only require 3 to be used. Keys must be
    specified in a base64 encoded fromat of the binary gpg public key.
    To ensure no Vault access is leaked into the Terraform state, this variable should be set to true.
  EOF

  type    = list(string)
  default = []
}

variable "recovery_threshold" {
  description = <<-EOF
    The number of recovery keys required to generate a root token or to rekey vault.
    This value should be equal or greater to the number of recovery_pgp_keys, or leave the default
    value of 1 if no recovery_pgp_keys are used.
  EOF
  type        = number
  default     = 1
}

variable "revoke_root_token" {
  description = <<-EOF
    Should the root token created as part of the init process be revoked. 
    If revoked an admin token must be obtained by logging into Vault using one of the admin service accounts.
    A new root token can always be generated using the recovery keys.
    To ensure no Vault access is leaked into the Terraform state, this variable should be set to true.
  EOF

  default = false
}
