# Configures GSuite as an OIDC/JWT provider and maps groups to Vault
# aliases to elevate privileges as needed.

resource "vault_jwt_auth_backend" "oidc" {
  type               = "oidc"
  path               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = var.gsuite_client_id
  oidc_client_secret = var.gsuite_client_secret
  default_role       = "domain_user"
  provider_config = {
    provider                 = "gsuite"
    gsuite_service_account   = var.gsuite_service_account_cred_path
    gsuite_admin_impersonate = var.gsuite_admin_impersonate_account
    fetch_groups             = true
    fetch_user_info          = false
    groups_recurse_max_depth = 5
    user_custom_schemas      = ""
  }
}

resource "vault_jwt_auth_backend_role" "domain_user" {
  backend   = vault_jwt_auth_backend.oidc.path
  role_name = "domain_user"
  role_type = vault_jwt_auth_backend.oidc.type
  allowed_redirect_uris = [
    "https://vault.lab.acceleratedgcp.com:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
  user_claim   = "sub"
  groups_claim = "groups"
  # Domain users get default policy always
  token_policies = ["default"]
}

# Link the Vault admin policy to the domain admin group
resource "vault_identity_group" "admins" {
  name = var.gsuite_admin_group
  type = "external"
  policies = [
    vault_policy.admin.name,
  ]
  metadata = {
    responsibility = "Admin Group"
  }
}

resource "vault_identity_group_alias" "admins_alias" {
  name           = var.gsuite_admin_group
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.admins.id
}
