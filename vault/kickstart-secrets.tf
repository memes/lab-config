# AppRole for access kickstart-secrets; this AppRole will be two-phase where
# Ansible can read the RoleID for embedding in kickstart scripts, and runtime
# scripts on hosts can retrieve the SecretID to access the KV values.

# Policy to allow reading of kickstart KV secrets
resource "vault_policy" "kickstart-secrets" {
  name   = "kickstart-secrets"
  policy = <<EOP
# Policy that allows the reading of kickstart secrets
path "${vault_mount.secret.path}/data/lab/kickstart" {
    capabilities = ["read", "list"]
}
EOP
}

# AppRole that uses the kickstart secret policy
resource "vault_approle_auth_backend_role" "kickstart-secrets" {
  backend   = vault_auth_backend.approle.path
  role_name = "kickstart-secrets"
  token_policies = [
    vault_policy.kickstart-secrets.name,

  ]
  # Default TTL is 5 minutes.
  token_ttl         = 300
  token_num_uses    = 10
  token_bound_cidrs = var.bound_cidrs
  # Secret TTL is 2 hours
  secret_id_ttl         = 7200
  secret_id_num_uses    = 10
  secret_id_bound_cidrs = var.bound_cidrs
}

# Policy that grants access to read AppRole RoleID
resource "vault_policy" "kickstart-secrets-roleid" {
  name   = "kickstart-secrets-roleid"
  policy = <<EOP
# Policy that allows reading of kickstart role-id
path "auth/${vault_auth_backend.approle.path}/role/${vault_approle_auth_backend_role.kickstart-secrets.role_name}/role-id" {
    capabilities = ["read"]
}
EOP
}

# Policy that grants access to generate a short lived SecretID to retrieve
# kickstart secret from KV store.
resource "vault_policy" "kickstart-secrets-secretid" {
  name   = "kickstart-secrets-secretid"
  policy = <<EOP
# Policy that allows update of kickstart secret-id
path "auth/${vault_auth_backend.approle.path}/role/${vault_approle_auth_backend_role.kickstart-secrets.role_name}/secret-id" {
    capabilities = ["update"]
}
EOP
}
