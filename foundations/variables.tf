variable "project_id" {
  type        = string
  description = "The unique identifier to use with the created project. Must be globally unique."
}

variable "folder_id" {
  type        = string
  default     = ""
  description = "An optional folder identifier under which the project will be created. Default is an empty string."
}

variable "billing_account" {
  type        = string
  description = "The GCP billing account to apply to the project. Executing user must have IAM permissions to associate the project to the billing account."
}

variable "terraform_sa_impersonators" {
  type        = list(string)
  description = "An optional list of users and/or groups that will be granted ability to impersonate the Terraform service account. Members must be fully-qualified with 'user:' or 'group:'."
  default     = []
}

variable "tf_sa_roles" {
  type        = list(string)
  description = "A list of IAM roles to assign to the Terraform service account."
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
  description = "A list of APIs to enable for the project."
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
    "drive.googleapis.com",
  ]
}
