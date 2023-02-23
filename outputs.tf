output "vault_url" {
  description = "The public URL to access the Vault server"
  value       = google_cloud_run_service.vault.status.0.url
}

output "root_token" {
  description = <<-EOF
    Root token that can be used to acccess vault, 
    will not be output when revoke_root_token is set to true
  EOF

  value = var.revoke_root_token ? null : local.root_token
}

output "recovery_keys" {
  description = <<-EOF
    Recovery keys that can be used to generate a Vault root token or
    rekey Vault. If the variable recovery_pgp_keys is set these keys will be
    encypted with using the recovery_pgp_keys.
  EOF
  value       = jsondecode(terracurl_request.vault_init.response).recovery_keys
}

output "recovery_keys_base64" {
  value = jsondecode(terracurl_request.vault_init.response).recovery_keys_base64
}
