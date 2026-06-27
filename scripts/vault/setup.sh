#!/bin/bash

set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-}"
MOUNT="tracepoint-n"
SECRET_PATH="access/ssh/targets"
POLICY_NAME="tracepoint-n"

export VAULT_ADDR VAULT_TOKEN

# Create KV v2 engine if not already mounted
if vault secrets list 2>/dev/null | grep -q "^${MOUNT}/"; then
  echo "Mount ${MOUNT} already exists, skipping."
else
  vault secrets enable -path="${MOUNT}" kv-v2
fi

# Create secret
vault kv put "${MOUNT}/${SECRET_PATH}" \
  username="changeme" \
  password="changeme"

# Create policy
vault policy write "${POLICY_NAME}" policy.hcl

# Generate token from policy
TOKEN=$(vault token create \
  -policy="${POLICY_NAME}")

echo "Token: ${TOKEN}"