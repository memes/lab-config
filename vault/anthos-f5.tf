# Enable GCP secrets engine for F5 Anthos lab rooted at /anthos-f5

resource "vault_gcp_secret_backend" "anthos_f5" {
  path        = "/anthos-f5"
  credentials = file("${path.module}/f5-anthos-lab.json")
  description = "GCP service account integration for F5 Anthos lab."
}

# Policy to allow reading of Anthos F5 service account keys
resource "vault_policy" "anthos_f5_sa_keys" {
  name   = "anthos-f5-sa-keys"
  policy = <<EOP
# Policy that allows the reading of service account keys from Anthos F5
path "${vault_gcp_secret_backend.anthos_f5.path}/key/" {
    capabilities = ["read"]
}
EOP
}

#
# GKE on-prem access to installation components
#
resource "vault_gcp_secret_roleset" "anthos_f5_component_access" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "component-access"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/serviceusage.serviceUsageViewer",
      "roles/iam.serviceAccountCreator",
      "roles/iam.roleViewer",
    ]
  }
}

#
# Registration agent for GKE on-prem
#
resource "vault_gcp_secret_roleset" "anthos_f5_connect_register" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "connect-register"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/gkehub.admin",
    ]
  }
}

#
# Anthos connection agent for GKE on-prem
#
resource "vault_gcp_secret_roleset" "anthos_f5_connect_agent" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "connect-agent"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/gkehub.connect",
    ]
  }
}

#
# GKE on-prem export logging and metrics to Stackdriver
#
resource "vault_gcp_secret_roleset" "anthos_f5_logging_monitoring" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "logging-monitoring"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/stackdriver.resourceMetadata.writer",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/monitoring.dashboardEditor",
    ]
  }
}

#
# GKE on-prem audit logging
# NOTE: this service account should not be bound to any IAM roles
#
resource "vault_gcp_secret_roleset" "anthos_f5_audit_logging" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "audit-logging"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = []
  }
}

#
# GKE on-prem binary authorisation
#
resource "vault_gcp_secret_roleset" "anthos_f5_binary_authorisation" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "binary-authorisation"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/binaryauthorization.policyEvaluator",
    ]
  }
}

#
# GKE usage metering
#
resource "vault_gcp_secret_roleset" "anthos_f5_usage_metering" {
  backend     = vault_gcp_secret_backend.anthos_f5.path
  roleset     = "usage-metering"
  secret_type = "service_account_key"
  project     = var.f5_anthos_project_id

  binding {
    resource = format("//cloudresourcemanager.googleapis.com/projects/%s", var.f5_anthos_project_id)

    roles = [
      "roles/bigquery.dataEditor",
    ]
  }
}
