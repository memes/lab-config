#!/bin/sh
#
# Shell script to perform an OTP login as root to Vault
#
# Use environment vars to override behaviour; e.g.
# VAULT_SKIP_VERIFY=true ./root-otp-login.sh UNSEAL_KEY
#

set -e

if [ $# -lt 1 ]; then
    echo "$0: unseal key must be provided as the only argument" >&2
    exit 1
fi
JSON="$(vault operator generate-root -init -format=json)"
NONCE="$(echo "${JSON}" | jq -r '.nonce')"
OTP="$(echo "${JSON}" | jq -r '.otp')"
ENC_TOKEN="$(vault operator generate-root -format=json -nonce ${NONCE} $@ | jq -r '.encoded_token')"
vault login "$(vault operator generate-root -decode "${ENC_TOKEN}" -otp "${OTP}")"
unset JSON NONCE OTP ENC_TOKEN
