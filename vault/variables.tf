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

variable "f5_anthos_project_id" {
  type        = string
  description = "The GCP project id for F5/Anthos integration lab."
}
