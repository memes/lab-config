# IPMI secret access role

# Policy to allow reading of ipmi secrets
resource "vault_policy" "ipmi-secrets" {
  name   = "ipmi-secrets"
  policy = <<EOP
# Policy that allows the reading of ipmi secrets
path "${vault_mount.secret.path}/data/lab/ipmi" {
    capabilities = ["read", "list"]
}
EOP
}

# Short lived AppRole to access KV ipmi-secrets
resource "vault_approle_auth_backend_role" "ipmi-secrets" {
  backend   = vault_auth_backend.approle.path
  role_name = "ipmi-secrets"
  token_policies = [
    vault_policy.ipmi-secrets.name,
  ]
  # Default TTL is 5 minutes, but a max of 1 hour is supported
  token_ttl             = 300
  token_max_ttl         = 3600
  token_bound_cidrs     = var.bound_cidrs
  secret_id_bound_cidrs = var.bound_cidrs
}
