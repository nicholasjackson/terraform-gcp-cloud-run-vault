resource "terracurl_request" "vault_disable_root_token" {
  count = var.revoke_root_token ? 1 : 0 

  depends_on = [
    resource.terracurl_request.vault_auth_role
  ]

  lifecycle {
    ignore_changes = [
      headers,
    ]
  }

  name = "vault root token disable"

  method       = "POST"
  url          = "${google_cloud_run_service.vault.status.0.url}/v1/auth/token/revoke-self"

  response_codes = [200, 204]
  headers = {
    "X-Vault-Token" = local.root_token
  }
}
