output "vault_url" {
  value = google_cloud_run_service.vault.status.0.url
}

output "root_token" {
  value = local.root_token
}
