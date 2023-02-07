//# Add the permissions to lookup tokens for the vault servers service account, this is needed for vault login with GCP
resource "google_project_iam_member" "vault_auth_role" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.vault_service_account.email}"
}

# Generate a Vault Admin policy
resource "terracurl_request" "vault_policy" {
  depends_on = [
    resource.google_cloud_run_service_iam_policy.noauth
  ]

  lifecycle {
    ignore_changes = [
      headers,
      destroy_headers
    ]
  }

  name = "vault admin policy"

  method         = "POST"
  url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/policies/acl/admin"
  request_body   = <<EOF
{
  "name": "admin",
  "policy": "${replace(replace(file("${path.module}/admin_policy.hcl"), "\"", "\\\""), "\n", "\\n")}"
}
EOF 
  response_codes = [200, 204]
  headers = {
    "X-Vault-Token" = local.root_token
  }

  destroy_url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/policies/acl/admin"
  destroy_method         = "DELETE"
  destroy_response_codes = [200, 204, 404]
  destroy_headers = {
    "X-Vault-Token" = local.root_token
  }
}

# Enable the GCP authentication
resource "terracurl_request" "vault_enable_auth" {
  depends_on = [
    resource.terracurl_request.vault_policy,

    # Add this dependency as on destroy the bucket access can be removed before auth endpoint
    # causing vault to fail when trying to revoke the leases
    resource.google_storage_bucket_iam_binding.vault_data_binding
  ]

  lifecycle {
    ignore_changes = [
      headers,
      destroy_headers
    ]
  }

  name = "vault auth enable"

  method       = "POST"
  url          = "${google_cloud_run_service.vault.status.0.url}/v1/sys/auth/gcp"
  request_body = <<EOF
{
  "type": "gcp"
}
EOF 

  response_codes = [200, 204]
  headers = {
    "X-Vault-Token" = local.root_token
  }

  destroy_url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/auth/gcp"
  destroy_method         = "DELETE"
  destroy_response_codes = [200, 204, 404]
  destroy_headers = {
    "X-Vault-Token" = local.root_token
  }
}

# Create a role that allows the specified service account ability to authenticate with vault and get admin rights
resource "terracurl_request" "vault_auth_role" {
  depends_on = [
    resource.terracurl_request.vault_enable_auth,

    # Add this dependency as on destroy the bucket access can be removed before auth endpoint
    # causing vault to fail when trying to revoke the leases
    resource.google_storage_bucket_iam_binding.vault_data_binding
  ]

  lifecycle {
    ignore_changes = [
      headers,
      destroy_headers
    ]
  }

  name = "vault admin"

  method         = "POST"
  url            = "${google_cloud_run_service.vault.status.0.url}/v1/auth/gcp/role/admin"
  request_body   = <<EOF
{
  "type": "iam",
  "project_id": "${var.project_id}",
  "policies": ["admin"],
  "bound_service_accounts": ["${var.service_account_email}"]
}
EOF 
  response_codes = [200, 204]
  headers = {
    "X-Vault-Token" = local.root_token
  }

  destroy_url            = "${google_cloud_run_service.vault.status.0.url}/v1/auth/gcp/role/admin"
  destroy_method         = "DELETE"
  destroy_response_codes = [200, 204, 404]
  destroy_headers = {
    "X-Vault-Token" = local.root_token
  }
}
