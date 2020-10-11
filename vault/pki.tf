# Configure certificate management:
#  - CA cert and key is created outside of Vault, but imported as a CA
#  - Intermediate and other certs are managed by Vault entirely

locals {
  # Change when it is time to rotate intermediate cert
  # TODO: @memes - wrong year in intermediate for 2023. D'Oh
  intermediate_cn = "Accelerated GCP Lab Intermediate CA 2024"
}

resource "vault_pki_secret_backend_config_urls" "pki_ca" {
  backend = vault_mount.pki_ca.path
  issuing_certificates = [
    "https://vault.lab.acceleratedgcp.com:8200/v1/pki_ca/ca",
  ]
  crl_distribution_points = [
    "https://vault.lab.acceleratedgcp.com:8200/v1/pki_ca/crl",
  ]
}

# NOTE: CA pem bundle *MUST* have been added to the pki_ca mount before
# intermediate can be generated. See README.md.

# Generate an intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = local.intermediate_cn
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Lab CA"
  organization         = "Accelerated GCP"
  country              = "United States"
  locality             = "Laguna Niguel"
  province             = "California"
}

# Sign intermediate CSR with root CA
resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend        = vault_mount.pki_ca.path
  csr            = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name    = local.intermediate_cn
  use_csr_values = true
  ttl            = "17520h"
  format         = "pem_bundle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "pki" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "https://vault.lab.acceleratedgcp.com:8200/v1/pki/ca",
  ]
  crl_distribution_points = [
    "https://vault.lab.acceleratedgcp.com:8200/v1/pki/crl",
  ]
}

# Role to create server certificates for TLS, etc.
resource "vault_pki_secret_backend_role" "server" {
  backend               = vault_mount.pki.path
  name                  = "server"
  ttl                   = 7776000
  max_ttl               = 31536000
  allow_localhost       = false
  allowed_domains       = var.server_domains
  allow_bare_domains    = false
  allow_subdomains      = true
  allow_any_name        = false
  enforce_hostnames     = true
  allow_ip_sans         = true
  server_flag           = true
  client_flag           = false
  code_signing_flag     = false
  email_protection_flag = false
  key_type              = "rsa"
  key_bits              = 4096
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
  ou           = ["Lab"]
  organization = ["Accelerated GCP"]
  country      = ["United States"]
  locality     = ["Laguna Niguel"]
  province     = ["California"]
  require_cn   = true
}

# Role to generate client certificates for person identification (VPN, etc)
resource "vault_pki_secret_backend_role" "person" {
  backend               = vault_mount.pki.path
  name                  = "person"
  ttl                   = 15552000
  max_ttl               = 31536000
  allow_localhost       = false
  allowed_domains       = var.person_domains
  allow_bare_domains    = true
  allow_subdomains      = false
  allow_any_name        = false
  enforce_hostnames     = true
  allow_ip_sans         = false
  server_flag           = false
  client_flag           = false
  code_signing_flag     = false
  email_protection_flag = true
  key_type              = "rsa"
  key_bits              = 4096
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
  ou           = ["Lab"]
  organization = ["Accelerated GCP"]
  country      = ["United States"]
  locality     = ["Laguna Niguel"]
  province     = ["California"]
  require_cn   = true
}

# Role to generate server certificates limited to 2048 bits (iDRAC, vCenter, etc.)
resource "vault_pki_secret_backend_role" "server_2048" {
  backend               = vault_mount.pki.path
  name                  = "server_2048"
  ttl                   = 7776000
  max_ttl               = 31536000
  allow_localhost       = false
  allowed_domains       = var.server_2048_domains
  allow_bare_domains    = false
  allow_subdomains      = true
  allow_any_name        = false
  enforce_hostnames     = true
  allow_ip_sans         = true
  server_flag           = true
  client_flag           = false
  code_signing_flag     = false
  email_protection_flag = false
  key_type              = "rsa"
  key_bits              = 2048
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
  ou           = ["Lab"]
  organization = ["Accelerated GCP"]
  country      = ["United States"]
  locality     = ["Laguna Niguel"]
  province     = ["California"]
  require_cn   = true
}
