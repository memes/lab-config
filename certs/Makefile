# List of the hosts/services to generate FQDN certificates with Lab domains
SHARED_SERVICES := repair shared vault vpn idr01 idr02 idr03
# List of personal certs to generate email style certificates for
PERSON_CERTS := memes

# Change if the domains ever change
# RFC8375 - https://datatracker.ietf.org/doc/html/rfc8375
LAN_DOMAIN_NAME := home.arpa
# Not an RFC8375 but shouldn't conflict with anything
LAB_DOMAIN_NAME := lab.acceleratedgcp.com

# Change as needed
CA_CERT_PEM := ../ca/acceleratedgcp-root-ca.pem

.PHONY: all clean
.PRECIOUS: %.key %.pem %.json %.csr

# Default target will ensure there are certs for all
all: $(addsuffix .$(LAB_DOMAIN_NAME).pem,$(SHARED_SERVICES)) $(addsuffix @$(LAB_DOMAIN_NAME).p12,$(PERSON_CERTS)) intermediate.pem

# Vault service TLS
vault.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=vault.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.2,172.16.10.2,2001:470:49a5::2,2001:470:49a5:10::2 > $@

# Repair is the firewall and router combo
repair.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=repair.$(LAN_DOMAIN_NAME),fwl01.$(LAB_DOMAIN_NAME),fwl01.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.1,172.16.10.1,2001:470:49a5::1,2001:470:49a5:10::1 > $@

# Shared provides internal HTTPS for installation and sharing of files
shared.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=shared.$(LAN_DOMAIN_NAME),sto01.$(LAB_DOMAIN_NAME),sto01.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.2,172.16.10.2,2001:470:49a5::2,2001:470:49a5:10::2 > $@

# VPN cert is used for IPSec authentication
vpn.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) > $@

# Create a personal cert for memes IPSec authentication
memes@$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/person \
		common_name=$(subst .json,,$@) > $@

# iDRAC certs must be 2048 bits generated from a CSR downloaded from iDRAC
idr01.$(LAB_DOMAIN_NAME).json: idr01.$(LAB_DOMAIN_NAME).csr
	vault write -format=json pki/sign/server_2048 \
		csr=@$< \
		format=pem_bundle > $@

idr02.$(LAB_DOMAIN_NAME).json: idr02.$(LAB_DOMAIN_NAME).csr
	vault write -format=json pki/sign/server_2048 \
		csr=@$< \
		format=pem_bundle > $@

idr03.$(LAB_DOMAIN_NAME).json: idr03.$(LAB_DOMAIN_NAME).csr
	vault write -format=json pki/sign/server_2048 \
		csr=@$< \
		format=pem_bundle > $@

# Extract a copy of current intermediate certificate
intermediate.pem:
	vault read -format=json pki/cert/ca | \
		jq -r '.data.certificate' > $@

### Helper recipes and clean target below

# Extract Certificate PEM from bundled json
%.pem: %.json %.key
	jq -r '.data.certificate + (.data.ca_chain | map("\n" + .))[]' < $< > $@

# Extract Certificate private key from bundled json
%.key: %.json
	jq -r '.data.private_key' < $< > $@

# Generate a PKCS12 file from cert and key pair
%.p12: %.pem %.key
	openssl pkcs12 -export -out $@ \
		-inkey $(word 2,$^) \
		-in $< \
		-certfile $(CA_CERT_PEM)

# Clean up all certs, keys, and json files
clean:
	-rm -f $(wildcard *.pem) $(wildcard *.key) $(wildcard *.json) $(wildcard *.p12)
