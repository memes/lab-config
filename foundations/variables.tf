variable "billing_account" {
  type        = string
  description = <<EOD
The GCP billing account to apply to the project. Executing user must have IAM permissions to associate the project to the billing account.
EOD
}

variable "tf_sa_roles" {
  type        = list(string)
  description = <<EOD
A list of IAM roles to assign to the Terraform service account.
EOD
  default = [
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin",
  ]
}

variable "apis" {
  type        = list(string)
  description = <<EOD
A list of APIs to enable for the project.
EOD
  default = [
    "cloudapis.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}
