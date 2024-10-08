#!/bin/sh
#
# Shell script to perform an OTP login as root to Vault
#
# Use environment vars to override behaviour; e.g.
# VAULT_SKIP_VERIFY=true ./root-otp-login.sh
#

set -e

JSON="$(vault operator generate-root -init -format=json)"
NONCE="$(echo "${JSON}" | jq -r '.nonce')"
OTP="$(echo "${JSON}" | jq -r '.otp')"
while true; do
    # shellcheck disable=SC3045
    read -r -s -p "Unseal token (leave empty when done): " token
    echo
    test -z "${token}" && break
    set -- "$@" "${token}"
done
for KEY in "$@"; do
    ENC_TOKEN="$(vault operator generate-root -format=json -nonce "${NONCE}" "${KEY}" | jq -r '.encoded_token')"
done
vault login "$(vault operator generate-root -decode "${ENC_TOKEN}" -otp "${OTP}")"
unset JSON NONCE OTP ENC_TOKEN KEY
