locals {
  root_token = terracurl_request.vault_init.response == null ? null : jsondecode(terracurl_request.vault_init.response).root_token
}


output "vault_url" {
  value = google_cloud_run_service.vault.status.0.url
}

output "root_token" {
  value = local.root_token
}

//data "google_service_account_access_token" "default" {
//  target_service_account = var.service_account_email
//  scopes = [
//    "cloud-platform",
//    "userinfo-email"
//  ]
//  lifetime = "300s"
//}
//
//
//data "google_service_account_id_token" "oidc" {
//  target_service_account = var.service_account_email
//  delegates              = []
//  include_email          = true
//  target_audience        = google_cloud_run_service.vault.status.0.url
//}
//
//output "token" {
//  sensitive = true
//  value     = data.google_service_account_id_token.oidc.id_token
//}
