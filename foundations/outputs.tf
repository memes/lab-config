output "project_id" {
  description = <<EOD
The project id for lab foundations project.
EOD
  value       = google_project.lab-config.project_id
}

output "tf_sa" {
  description = <<EOD
The service account used by Terraform.
EOD
  value       = google_service_account.terraform.email
}
