# Configure Hashicorp Vault for use in lab
terraform {
  required_version = "~> 1.3"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    vault = {
      # Provider is configured through environment vars to facilitate bootstrapping
      # and updates.
      # See https://registry.terraform.io/providers/hashicorp/vault/latest/docs#provider-arguments
      source  = "hashicorp/vault"
      version = "~> 3.10"
    }
  }
  backend "gcs" {}
}

provider "vault" {}

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
path "${vault_mount.secret.path}/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete PKI engine.
path "${vault_mount.pki.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete PKI CA engine.
path "${vault_mount.pki_ca.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOP
}

resource "vault_policy" "audit" {
  name   = "audit"
  policy = <<EOP
# 'sudo' capability is required to manage audit devices
path "sys/audit/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# To list enabled audit devices, 'sudo' capability is required
path "sys/audit"
{
  capabilities = ["read", "sudo"]
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
