terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "4.51.0"
    }

    terracurl = {
      source  = "devops-rob/terracurl"
      version = "0.1.1"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# Create a service account for the Vault server
resource "google_service_account" "vault_service_account" {
  account_id   = "vault-server"
  display_name = "Vault Service Account"
}

# Add the permissions to lookup tokens for the vault servers service account, this is needed for vault login with GCP
resource "google_project_iam_member" "vault_auth_role" {
  project = google_service_account.vault_service_account.project

  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

# Add permission for the vault serviced account to call the authenticated Vault URL before Vault is unsealed
resource "google_project_iam_member" "vault_invoker_role" {
  project = google_service_account.vault_service_account.project

  role   = "roles/run.admin"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

# Generate a random id so that the bucket name is unique
resource "random_id" "bucket_id" {
  byte_length = 8
}

# Create a storage bucket for the Vault data
resource "google_storage_bucket" "vault_data" {
  name          = "vault-data-${random_id.bucket_id.hex}"
  location      = var.region
  force_destroy = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket_iam_binding" "vault_data_binding" {
  bucket = google_storage_bucket.vault_data.name
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.vault_service_account.email}",
  ]
}

# Create a keymanager for the unseal keys, keys can not be deleted once created, they are only removed from the state
resource "google_kms_key_ring" "vault_unseal" {
  count    = var.create_kms_keyring_and_key ? 1 : 0
  name     = "vault-unseal-key"
  location = "global"
}

# Create an unseal key for Vault, keys can not be deleted once created
resource "google_kms_crypto_key" "vault_unseal" {
  count    = var.create_kms_keyring_and_key ? 1 : 0
  name     = "unseal"
  key_ring = google_kms_key_ring.vault_unseal.0.id
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_encrypt" {
  crypto_key_id = data.google_kms_crypto_key.vault_unseal.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.vault_service_account.email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_get" {
  crypto_key_id = data.google_kms_crypto_key.vault_unseal.id
  role          = "roles/cloudkms.viewer"

  members = [
    "serviceAccount:${google_service_account.vault_service_account.email}",
  ]
}

data "google_kms_crypto_key" "vault_unseal" {
  name     = "unseal"
  key_ring = data.google_kms_key_ring.vault_unseal.id
}

data "google_kms_key_ring" "vault_unseal" {
  name     = "vault-unseal-key"
  location = "global"
}

# Add the Vault config to the secrets manager
resource "google_secret_manager_secret" "vault_server_config" {
  secret_id = "vault-server-config"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "vault_server_config_version" {
  secret = google_secret_manager_secret.vault_server_config.id

  secret_data = templatefile("${path.module}/config.tmpl", {
    gcp_key_ring       = "vault-unseal-key"
    gcp_key_name       = "unseal"
    gcp_key_region     = "global"
    gcp_storage_bucket = google_storage_bucket.vault_data.name
    gcp_project        = var.project
  })
}

# Grant the Vault server permission to read the config
resource "google_secret_manager_secret_iam_binding" "vault_server_binding" {
  secret_id = google_secret_manager_secret.vault_server_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.vault_service_account.email}",
  ]
}

# Run Vault in CloudRun
resource "google_cloud_run_service" "vault" {
  name     = "vault-server"
  location = var.region

  template {
    spec {
      containers {
        image = "docker.io/library/vault:1.12.2"

        startup_probe {
          initial_delay_seconds = 180
          timeout_seconds       = 3
          period_seconds        = 10
          failure_threshold     = 5

          http_get {
            path = "/v1/sys/seal-status"
          }
        }

        env {
          name  = "SKIP_SETCAP"
          value = "1"
        }

        ports {
          name           = "http1"
          container_port = 8200
        }

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }

          requests = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        volume_mounts {
          name       = "vault-config"
          mount_path = "/vault/config"
        }

        args = ["vault", "server", "-config", "/vault/config"]

      }

      volumes {
        name = "vault-config"
        secret {
          secret_name = google_secret_manager_secret.vault_server_config.secret_id
          items {
            key  = google_secret_manager_secret_version.vault_server_config_version.version
            path = "config.hcl"
          }
        }
      }

      service_account_name = google_service_account.vault_service_account.email

    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
        "autoscaling.knative.dev/minScale" = "1"
      }
    }
  }
}

# Initialize vault and get the root token sinced vault is currently not initialized
# it is not open to public requests, we need to use an oidc token
data "google_service_account_id_token" "oidc" {
  target_service_account = google_service_account.vault_service_account.email
  delegates              = []
  include_email          = true
  target_audience        = google_cloud_run_service.vault.status.0.url
}

resource "terracurl_request" "vault_init" {
  name = "vault init"

  lifecycle {
    ignore_changes = [
      headers,
    ]
  }

  method         = "POST"
  url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/init"
  request_body   = file("${path.module}/init.json")
  response_codes = [200]
  headers = {
    "Authorization" = "Bearer ${data.google_service_account_id_token.oidc.id_token}"
  }
}

locals {
  root_token = terracurl_request.vault_init.response == null ? null : jsondecode(terracurl_request.vault_init.response).root_token
}

# Disable authentication for the Vault server now that it is initialized
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  depends_on = [
    resource.terracurl_request.vault_init
  ]

  location = google_cloud_run_service.vault.location
  project  = google_cloud_run_service.vault.project
  service  = google_cloud_run_service.vault.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
