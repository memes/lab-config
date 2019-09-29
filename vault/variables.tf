variable "tf_sa" {
  type        = string
  description = <<EOD
The email address associated with the GCP service account that will be used to create and manage resources. E.g.
tf_sa = "terraform@project-id.iam.gserviceaccount.com"
EOD
}

variable "project_id" {
  type        = string
  description = <<EOD
The unique identifier for the GCP project that will be used for Vault persistence.
EOD
}
