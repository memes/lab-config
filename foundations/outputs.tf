output "project_id" {
  description = <<EOD
The project id for lab foundations project
EOD
  value       = google_project.lab-config.project_id
}

output "tf_sa" {
  description = <<EOD
EOD
  value       = google_service_account.terraform.email
}
