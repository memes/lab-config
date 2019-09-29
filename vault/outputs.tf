output "vault_sa" {
  description = <<EOD
The GCP service account that has access to Vault GCS storage bucket. The Vault
service will have to use this account for all GCS operations.
EOD
  value       = google_service_account.vault.email
}

output "vault_bucket" {
  description = <<EOD
The randomly named GCS bucket that will be used for Vault storage.
EOD
  value       = random_id.vault_bucket_name.hex
}

output "vault_key" {
  description = <<EOD
The GCP service account JSON key file, base64 encoded, that must be used to
authenticate as the Vault service account.
EOD
  value       = google_service_account_key.vault.private_key
}
