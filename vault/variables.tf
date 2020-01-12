variable "server_domains" {
  type = list(string)
  default = [
    "home.arpa",
    "lab.arpa",
  ]
  description = "The list of domains that will be permitted for server CSRs."
}

variable "person_domains" {
  type = list(string)
  default = [
    "home.arpa",
    "lab.arpa",
  ]
  description = "The list of domains that will be permitted for person (VPN) CSRs."
}

variable "server_2048_domains" {
  type = list(string)
  default = [
    "lab.arpa",
  ]
  description = "The list of domains that will be permitted for server CSRs that must be restricted to 2048 bits (iDRAC)."
}
