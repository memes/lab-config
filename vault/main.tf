# Configure Hashicorp Vault for use in lab
terraform {
  required_version = "~> 0.14"
  required_providers {
    vault = {
      # Provider is configured through environment vars to facilitate bootstrapping
      # and updates.
      # See https://registry.terraform.io/providers/hashicorp/vault/latest/docs#provider-arguments
      source  = "hashicorp/vault"
      version = "2.18.0"
    }
  }
  backend "gcs" {}
}

# Enable KV v2 secret store
resource "vault_mount" "secret" {
  path = "secret"
  type = "kv"
  options = {
    version = 2
  }
}

# Enable AppRole support
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle"
}

# Externally sourced CA is mounted at /pki_ca
resource "vault_mount" "pki_ca" {
  path = "pki_ca"
  type = "pki"
  # CA should allow upto 10 years, with a default of 1 year
  default_lease_ttl_seconds = 31536000
  max_lease_ttl_seconds     = 315360000
}

# Vault managed certs are mounted at /pki
resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"
  # Certs should default to 1 hour TTL, with maximum of a year
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31536000
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<EOP
# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# List, create, update, and delete KV secrets.
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete PKI engine.
path "pki/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete PKI CA engine.
path "pki_ca/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}


# List, create, update, and delete F5 Anthos engine.
path "anthos-f5/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOP
}

resource "vault_policy" "update-token" {
  name   = "update-token"
  policy = <<EOP
# Allow account to retrieve an updated token
path "auth/token/create" {
    capabilities = ["update"]
}
EOP
}
