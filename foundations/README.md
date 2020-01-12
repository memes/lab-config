# Foundations

This folder contains Terraform to create a foundational GCP project for
Accelerated GCP Lab. These resources will be created:

* Google Cloud Project
  * Terraform service account w/selected roles
    * Impersonation rights bound to specified users/group
    * GCS bucket for Terraform state
  * Hashicorp Vault service account
    * GCS bucket for Hashicorp Vault state
    * Vault service account has roles to create keys and tokens for other
      service accounts as needed
  * OPNSense service account with no roles (used for automatic backups to GSuite
    drive)

<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| apis | A list of APIs to enable for the project. | list(string) | `[ "cloudapis.googleapis.com", "compute.googleapis.com", "logging.googleapis.com", "monitoring.googleapis.com", "oslogin.googleapis.com", "servicemanagement.googleapis.com", "serviceusage.googleapis.com", "storage-api.googleapis.com", "storage-component.googleapis.com", "iam.googleapis.com", "cloudresourcemanager.googleapis.com", "drive.googleapis.com" ]` | no |
| billing\_account | The GCP billing account to apply to the project. Executing user must have IAM permissions to associate the project to the billing account. | string | n/a | yes |
| folder\_id | An optional folder identifier under which the project will be created. Default is an empty string. | string | `""` | no |
| project\_id | The unique identifier to use with the created project. Must be globally unique. | string | n/a | yes |
| terraform\_sa\_impersonators | An optional list of users and/or groups that will be granted ability to impersonate the Terraform service account. Members must be fully-qualified with 'user:' or 'group:'. | list(string) | `[]` | no |
| tf\_sa\_roles | A list of IAM roles to assign to the Terraform service account. | list(string) | `[ "roles/compute.admin", "roles/iam.serviceAccountAdmin", "roles/iam.serviceAccountKeyAdmin", "roles/iam.serviceAccountTokenCreator", "roles/iam.serviceAccountUser", "roles/storage.admin", "roles/resourcemanager.projectIamAdmin" ]` | no |

## Outputs

| Name | Description |
|------|-------------|
| opnsense\_sa | The service account used by OPNsense. |
| project\_id | The project id for lab foundations project. |
| tf\_sa | The service account used by Terraform. |
| vault\_bucket | The randomly named GCS bucket that will be used for Vault storage. |
| vault\_key | The GCP service account JSON key file, base64 encoded, that must be used to authenticate as the Vault service account. |
| vault\_sa | The GCP service account that has access to Vault GCS storage bucket. The Vault service will have to use this account for all GCS operations. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
