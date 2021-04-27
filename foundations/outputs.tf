output "project_id" {
  description = "The project id for lab foundations project."
  value       = google_project.lab-config.project_id
}

output "tf_sa" {
  description = "The service account used by Terraform."
  value       = google_service_account.terraform.email
}

output "vault_sa" {
  description = "The GCP service account that has access to Vault GCS storage bucket. The Vault service will have to use this account for all GCS operations."
  value       = google_service_account.vault.email
}

output "vault_bucket" {
  description = "The randomly named GCS bucket that will be used for Vault storage."
  value       = random_id.vault_bucket_name.hex
}

output "vault_key" {
  description = "The GCP service account JSON key file, base64 encoded, that must be used to authenticate as the Vault service account."
  value       = google_service_account_key.vault.private_key
  sensitive   = true
}

output "opnsense_sa" {
  description = "The service account used by OPNsense."
  value       = google_service_account.opnsense.email
}
