# List of the hosts/services to generate FQDN certificates with Lab domains
SHARED_SERVICES := emerald shared vault vpn idr01 idr02 idr03
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
.PRECIOUS: %.key.pem %.chain.pem %.cert.pem %.json %.csr kubernetes/%.key kubernetes/%.crt kubernetes/%.json

# Default target will ensure there are certs for all
all: $(addsuffix .$(LAB_DOMAIN_NAME).chain.pem,$(SHARED_SERVICES)) \
	$(addsuffix @$(LAB_DOMAIN_NAME).p12,$(PERSON_CERTS)) \
		intermediate.cert.pem intermediate.chain.pem \
		repair.$(LAN_DOMAIN_NAME).chain.pem \
 		patent.$(LAN_DOMAIN_NAME).pfx \
		richard.$(LAB_DOMAIN_NAME).root.pem richard.$(LAB_DOMAIN_NAME).server.pem richard.$(LAB_DOMAIN_NAME).dhparams.pem \
		kubernetes/ca.crt kubernetes/ca.key kubernetes/etcd-ca.crt kubernetes/etcd-ca.key \
		kubernetes/front-proxy-ca.crt kubernetes/front-proxy-ca.key kubernetes/sa.pub kubernetes/sa.key \
		kubernetes/ca.chain.pem

# Vault service TLS
vault.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=vault.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.2,2001:470:49a5::2 > $@

# Repair and emerald are firewall and router combos; repair is not handling any
# lab traffic at this time.
repair.$(LAN_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=fwl01.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.2.1 > $@

emerald.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=emerald.$(LAN_DOMAIN_NAME),fwl02.$(LAB_DOMAIN_NAME),fwl02.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.1,172.16.10.1,2001:470:49a5::1,2001:470:49a5:10::1 > $@

# Shared provides internal HTTPS for installation and sharing of files
shared.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=shared.$(LAN_DOMAIN_NAME),sto01.$(LAB_DOMAIN_NAME),sto01.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.2,2001:470:49a5::2 > $@

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
		format=pem > $@

idr02.$(LAB_DOMAIN_NAME).json: idr02.$(LAB_DOMAIN_NAME).csr
	vault write -format=json pki/sign/server_2048 \
		csr=@$< \
		format=pem > $@

idr03.$(LAB_DOMAIN_NAME).json: idr03.$(LAB_DOMAIN_NAME).csr
	vault write -format=json pki/sign/server_2048 \
		csr=@$< \
		format=pem > $@

# Extract a copy of current intermediate certificate
intermediate.cert.pem:
	vault read -format=json pki/cert/ca | \
		jq -r '.data.certificate' > $@

intermediate.chain.pem: $(CA_CERT_PEM) intermediate.cert.pem
	cat $^ > $@

# Various networking services on LAN
patent.$(LAN_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server \
		common_name=$(subst .json,,$@) \
		alt_names=ctl01.$(LAN_DOMAIN_NAME) \
		ip_sans=172.16.0.7 > $@

# NOTE: 4096 bit cert bogs down this switch, so use 2048
richard.$(LAB_DOMAIN_NAME).json:
	vault write -format=json pki/issue/server_2048 \
		common_name=$(subst .json,,$@) \
		alt_names=swt02.$(LAB_DOMAIN_NAME) \
		ip_sans=172.16.10.9 > $@

# richard helpers to make sure the combos are correct
richard.$(LAB_DOMAIN_NAME).root.pem: richard.$(LAB_DOMAIN_NAME).json
	jq -r '.data.certificate' < $< > $@

richard.$(LAB_DOMAIN_NAME).server.pem: richard.$(LAB_DOMAIN_NAME).json intermediate.cert.pem
	cat intermediate.cert.pem > $@
	jq -r '.data.private_key' < $< >> $@

richard.$(LAB_DOMAIN_NAME).dhparams.pem: richard.$(LAB_DOMAIN_NAME).json
	openssl dhparam -out $@ 1024

### General helper recipes and clean target below

# Extract Certificate with chain as PEM from bundled json
%.chain.pem: %.json %.key.pem
	jq -r '([.data.certificate] + .data.ca_chain)[]' < $< > $@

# Extract Certificate only as PEM from bundled json
%.cert.pem: %.json %.key.pem
	jq -r '.data.certificate' < $< > $@

# Extract Certificate private key from bundled json
%.key.pem: %.json
	jq -r '.data.private_key' < $< > $@

# Generate a PKCS12 file from cert and key pair
%.p12: %.chain.pem %.key.pem
	openssl pkcs12 -export -out $@ \
		-inkey $(word 2,$^) \
		-in $< \
		-certfile $(CA_CERT_PEM)

# Generate a PKCS12 file from cert and key pair named as .pfx - OC200 controller is fussy
%.pfx: %.chain.pem %.key.pem
	openssl pkcs12 -export -out $@ \
		-inkey $(word 2,$^) \
		-in $< \
		-certfile $(CA_CERT_PEM)

# Clean up all certs, keys, and json files
clean:
	-rm -f $(wildcard *.chain.pem) $(wildcard *.cert.pem) $(wildcard *.key.pem) $(wildcard *.json) \
		$(wildcard *.p12) $(wildcard *.pfx) $(wildcard richard.$(LAB_DOMAIN_NAME).*) \
		$(wildcard kubernetes/*.crt) $(wildcard kubernetes/*.key) $(wildcard kubernetes/*.pub) \
		$(wildcard kubernetes/*.chain.pem) $(wildcard kubernetes/*.json)


### Kubernetes CAs and service account keys

kubernetes/ca.json:
	mkdir -p $(@D) && \
		vault write -format=json pki/intermediate/generate/exported \
			common_name="kubernetes-ca" \
			format=pem \
			key_type=rsa \
			key_bits=4096 \
			exclude_cn_from_sans=true \
			ou="Lab Cluster" \
			organization="Accelerated GCP" \
			country="US" \
			locality="Laguna Niguel" \
			province="California" > $@

kubernetes/etcd-ca.json:
	mkdir -p $(@D) && \
		vault write -format=json pki/intermediate/generate/exported \
			common_name="etcd-ca" \
			format=pem \
			key_type=rsa \
			key_bits=4096 \
			exclude_cn_from_sans=true \
			ou="Lab Cluster" \
			organization="Accelerated GCP" \
			country=US \
			locality="Laguna Niguel" \
			province="California" > $@

kubernetes/front-proxy-ca.json:
	mkdir -p $(@D) && \
		vault write -format=json pki/intermediate/generate/exported \
			common_name="kubernetes-front-proxy-ca" \
			format=pem \
			key_type=rsa \
			key_bits=4096 \
			exclude_cn_from_sans=true \
			ou="Lab Cluster" \
			organization="Accelerated GCP" \
			country=US \
			locality="Laguna Niguel" \
			province="California" > $@

kubernetes/sa.key:
	mkdir -p $(@D) && \
		openssl genrsa -traditional -out $@ 4096

kubernetes/sa.pub: kubernetes/sa.key
	openssl rsa -in $< -pubout > $@

kubernetes/%.key: kubernetes/%.json
	jq -r '.data.private_key' < $< > $@

kubernetes/%.csr: kubernetes/%.json
	jq -r '.data.csr' < $< > $@

kubernetes/%.crt: kubernetes/%.csr kubernetes/%.key
	vault write -format=json pki/root/sign-intermediate \
			format=pem \
			ttl="2160h" \
			csr=@$< | \
		jq -r '.data.certificate' > $@

kubernetes/ca.chain.pem: kubernetes/ca.crt intermediate.cert.pem $(CA_CERT_PEM)
	cat $^ > $@
