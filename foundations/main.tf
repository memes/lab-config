# This file creates the foundations for the lab-config project, including
# creation of service account(s) that will be used by infrastructure as code
# tools.

terraform {
  required_version = "~> 0.12"
  # Once the Terraform state bucket has been created, uncomment these lines and
  # re-init Terraform so that state can be transferred to GCS.
  # NOTE: the configuration values for bucket and prefix *MUST* be provided during
  # `terraform init -backend-config=CONFIG-FILE`
  backend "gcs" {}
}

provider "google" {
}

# Create the lab-config project
resource "google_project" "lab-config" {
  name       = "lab-config"
  project_id = var.project_id
  folder_id  = var.folder_id
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
  members            = var.terraform_sa_impersonators
}

# Create a bucket for Terraform state
resource "google_storage_bucket" "tf-state" {
  project  = google_project.lab-config.project_id
  name     = format("%s-terraform-state", var.project_id)
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

# Create a service account that Vault can use
resource "google_service_account" "vault" {
  project      = google_project.lab-config.project_id
  account_id   = "vault-sa"
  display_name = "Hashicorp Vault service account"
}

# Generate a service account key to use with Vault
resource "google_service_account_key" "vault" {
  service_account_id = google_service_account.vault.name
  key_algorithm      = "KEY_ALG_RSA_2048"
  public_key_type    = "TYPE_X509_PEM_FILE"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# Generate a random name for the bucket - it'll only ever be used by a Vault
# instance
resource "random_id" "vault_bucket_name" {
  byte_length = 8
}

# Create the bucket for Vault persistence
resource "google_storage_bucket" "vault-gcs" {
  project  = google_project.lab-config.project_id
  name     = random_id.vault_bucket_name.hex
  location = "US"
  versioning {
    enabled = false
  }
}

# Set IAM policy for the bucket.
data "google_iam_policy" "vault-gcs" {
  binding {
    role = "roles/storage.admin"
    members = [
      "group:lab-admins@matthewemes.com",
      "serviceAccount:${google_service_account.terraform.email}",
    ]
  }

  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${google_service_account.vault.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "vault-gcs" {
  bucket      = google_storage_bucket.vault-gcs.name
  policy_data = data.google_iam_policy.vault-gcs.policy_data
}

# Allow the Vault SA to generate authentication tokens - actual binding against
# target accounts will occur elsewhere.
resource "google_project_iam_member" "vault-sa-key-admin" {
  project = google_project.lab-config.project_id
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${google_service_account.vault.email}"
}

# Create a service account for OPNsense backups; roles are manually handled in
# GSuite admin console.
resource "google_service_account" "opnsense" {
  account_id   = "opnsense-sa"
  project      = google_project.lab-config.project_id
  display_name = "OPNsense service account for config backups"
}
