
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

resource "terracurl_request" "additional_admin_policy" {
  count = length(var.additional_admin_policy) > 0 ? 1 : 0

  depends_on = [
    resource.google_cloud_run_service_iam_policy.noauth
  ]

  lifecycle {
    ignore_changes = [
      headers,
      destroy_headers
    ]
  }

  name = "vault additional admin policy"

  method         = "POST"
  url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/policies/acl/admin_additional"
  request_body   = <<EOF
{
  "name": "admin_additonal",
  "policy": "${replace(replace(var.additional_admin_policy, "\"", "\\\""), "\n", "\\n")}"
}
EOF 
  response_codes = [200, 204]
  headers = {
    "X-Vault-Token" = local.root_token
  }

  destroy_url            = "${google_cloud_run_service.vault.status.0.url}/v1/sys/policies/acl/admin_additonal"
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

locals {
  admin_policies = length(var.additional_admin_policy) > 0 ? ["admin", "additional_admin_policy"] : ["admin"]
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
  "policies": ${jsonencode(local.admin_policies)},
  "bound_service_accounts": ${jsonencode(var.admin_service_accounts)}
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
