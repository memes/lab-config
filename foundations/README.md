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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project.lab-config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_member.sa-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.vault-sa-key-admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.opnsense](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.impersonate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_key.vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.tf-state](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.vault-gcs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.tf-admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_policy.vault-gcs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_policy) | resource |
| [random_id.vault_bucket_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_iam_policy.vault-gcs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The GCP billing account to apply to the project. Executing user must have IAM permissions to associate the project to the billing account. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The unique identifier to use with the created project. Must be globally unique. | `string` | n/a | yes |
| <a name="input_apis"></a> [apis](#input\_apis) | A list of APIs to enable for the project. | `list(string)` | <pre>[<br>  "cloudapis.googleapis.com",<br>  "compute.googleapis.com",<br>  "logging.googleapis.com",<br>  "monitoring.googleapis.com",<br>  "oslogin.googleapis.com",<br>  "servicemanagement.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "storage-api.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "iam.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "drive.googleapis.com"<br>]</pre> | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | An optional folder identifier under which the project will be created. Default is an empty string. | `string` | `""` | no |
| <a name="input_terraform_sa_impersonators"></a> [terraform\_sa\_impersonators](#input\_terraform\_sa\_impersonators) | An optional list of users and/or groups that will be granted ability to impersonate the Terraform service account. Members must be fully-qualified with 'user:' or 'group:'. | `list(string)` | `[]` | no |
| <a name="input_tf_sa_roles"></a> [tf\_sa\_roles](#input\_tf\_sa\_roles) | A list of IAM roles to assign to the Terraform service account. | `list(string)` | <pre>[<br>  "roles/compute.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/iam.serviceAccountUser",<br>  "roles/storage.admin",<br>  "roles/resourcemanager.projectIamAdmin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opnsense_sa"></a> [opnsense\_sa](#output\_opnsense\_sa) | The service account used by OPNsense. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The project id for lab foundations project. |
| <a name="output_tf_sa"></a> [tf\_sa](#output\_tf\_sa) | The service account used by Terraform. |
| <a name="output_vault_bucket"></a> [vault\_bucket](#output\_vault\_bucket) | The randomly named GCS bucket that will be used for Vault storage. |
| <a name="output_vault_key"></a> [vault\_key](#output\_vault\_key) | The GCP service account JSON key file, base64 encoded, that must be used to authenticate as the Vault service account. |
| <a name="output_vault_sa"></a> [vault\_sa](#output\_vault\_sa) | The GCP service account that has access to Vault GCS storage bucket. The Vault service will have to use this account for all GCS operations. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
