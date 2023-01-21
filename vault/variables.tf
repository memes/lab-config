variable "server_domains" {
  type = list(string)
  default = [
    "home.arpa",
    "lab.acceleratedgcp.com",
  ]
  description = "The list of domains that will be permitted for server CSRs."
}

variable "person_domains" {
  type = list(string)
  default = [
    "home.arpa",
    "lab.acceleratedgcp.com",
  ]
  description = "The list of domains that will be permitted for person (VPN) CSRs."
}

variable "server_2048_domains" {
  type = list(string)
  default = [
    "lab.acceleratedgcp.com",
  ]
  description = "The list of domains that will be permitted for server CSRs that must be restricted to 2048 bits (iDRAC)."
}

variable "gsuite_client_id" {
  type        = string
  description = "The GSuite OIDC client id."
}

variable "gsuite_client_secret" {
  type        = string
  description = "The GSuite OIDC client secret."
}

variable "gsuite_service_account_cred_path" {
  type        = string
  description = "The path to the JSON credentials for a GCP service account with access to GSuite user data."
}

variable "gsuite_admin_impersonate_account" {
  type        = string
  description = "The GSuite administrative user account that will be impersonated for API calls."
}

variable "gsuite_admin_group" {
  type        = string
  description = "GSuite group that will be granted Vault admin role on authentication."
}

variable "bound_cidrs" {
  type        = list(string)
  description = "A list of CIDRs that will be permitted to access tokens and secrets."
}
