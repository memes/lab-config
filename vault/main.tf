terraform {
  required_version = "~> 0.12"
  backend "gcs" {
    bucket = "lab-config-terraform-state"
    prefix = "vault"
  }
}

# This is the Google provider that executes as the *CURRENT USER* (human or
# service account). This provider is used to get an OAUTH2 token that the
# un-aliased Google/Google Beta provider(s) use for actual resource management.
provider "google" {
  alias = "executor"
}

#
data "google_client_config" "executor" {
  provider = google.executor
}

# Generate an access token for the Terraform service account, if the current
# user has the appropriate roles to impersonate the target service account.
data "google_service_account_access_token" "sa-token" {
  provider               = google.executor
  target_service_account = var.tf_sa
  lifetime               = "1200s"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

# This is the Google provider that will be used for resource management. It
# uses an OAUTH token instead of PKI, allowing effective use of another
# service account without sharing keys.
provider "google" {
  access_token = data.google_service_account_access_token.sa-token.access_token
}

# Create a service account that Vault can use
resource "google_service_account" "vault" {
  project      = var.project_id
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
  project  = var.project_id
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
      "serviceAccount:${var.tf_sa}",
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
  project = var.project_id
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${google_service_account.vault.email}"
}
