# This file creates the foundations for the lab-config project, including
# creation of service account(s) that will be used by infrastructure as code
# tools.

terraform {
  required_version = "~> 0.12"
  # Once the Terraform state bucket has been created, uncomment these lines and
  # re-init Terraform so that state can be transferred to GCS.
  backend "gcs" {
    bucket = "lab-config-terraform-state"
    prefix = "foundations"
  }
}

provider "google" {
}

# Create the lab-config project
resource "google_project" "lab-config" {
  name       = "lab-config"
  project_id = "lab-config"
  # Add the project to the acceleratedgcp folder
  folder_id = "987892363507"
  # Pull the billing account info from command line
  billing_account = var.billing_account
  # Don't need the default network
  auto_create_network = false
}

# Create a service account to be used by Terraform
resource "google_service_account" "terraform" {
  account_id   = "terraform"
  project      = google_project.lab-config.project_id
  display_name = "Terraform Service Account"
}

# Give impersonation privileges to Terraform service account for members of
# lab-admins group.
resource "google_service_account_iam_binding" "impersonate" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "group:lab-admins@matthewemes.com",
  ]
}

# Create a bucket for Terraform state
resource "google_storage_bucket" "tf-state" {
  project  = google_project.lab-config.project_id
  name     = "lab-config-terraform-state"
  location = "US"
  versioning {
    enabled = true
  }
}

# Grant the Terraform service account full control of the bucket
resource "google_storage_bucket_iam_member" "tf-admin" {
  bucket = google_storage_bucket.tf-state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Enable GCP APIs
resource "google_project_service" "apis" {
  count                      = length(var.apis)
  project                    = google_project.lab-config.project_id
  service                    = element(var.apis, count.index)
  disable_dependent_services = true
}

# Assign IAM project roles to the Terraform service account
resource "google_project_iam_member" "sa-roles" {
  count      = length(var.tf_sa_roles)
  project    = google_project.lab-config.project_id
  role       = element(var.tf_sa_roles, count.index)
  member     = "serviceAccount:${google_service_account.terraform.email}"
  depends_on = [google_project_service.apis]
}
