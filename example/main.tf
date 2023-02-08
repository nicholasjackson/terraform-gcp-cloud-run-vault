variable "project_id" {
  description = "Project ID in GCP"
  type        = string
}

variable "region" {
  description = "Region to deploy GCP resources"
  type        = string
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vault" {
  source = "../"

  region  = var.region
  project = var.project_id

  admin_service_accounts  = ["1060272596826-compute@developer.gserviceaccount.com"]

  additional_admin_policy = <<-EOF
    # Manage database mounts
    path "database/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    
    # Enable permission to manage secrets
    path "secret/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  EOF

  create_kms_keyring_and_key = false 
}

output "vault_url" {
  value = module.vault.vault_url
}

output "root_token" {
  value = module.vault.root_token
}
