# Manage Vault secrets for Kubernetes

# Issues using oidc_discovery_url/jwks_url/etc with/without setting
# kube-apiserver options service-account-issuer and/or service-account-jwks-uri.
# Deciding to setup the jwt auth at /k8s minimally, and update as necessary in
# the external-secrets Ansible role.
resource "vault_auth_backend" "k8s" {
  type = "jwt"
  path = "k8s"
}

# Policy to allow listing and reading of all Kubernetes credentials
resource "vault_policy" "k8s_default" {
  name   = "k8s_default"
  policy = <<EOP
# Policy that allows the listing secrets in k8s
path "${vault_mount.secret.path}/data/lab/k8s" {
    capabilities = ["list", "read"]
}
EOP
}

resource "vault_jwt_auth_backend_role" "k8s_default" {
  role_name = "k8s_default"
  backend   = vault_auth_backend.k8s.path
  role_type = vault_auth_backend.k8s.type
  token_policies = [
    vault_policy.k8s_default.name,
  ]
  bound_audiences = [
    "https://control.lab.acceleratedgcp.com:6443",
  ]
  # TODO @memes - change to external-secrets sa
  bound_subject = "system:serviceaccount:default:default"
  user_claim    = "sub"
  token_ttl     = 3600
  token_max_ttl = 3600
}
