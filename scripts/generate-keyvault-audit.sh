#!/bin/sh

keyvault_name="kv-nrg-sef-rksl2exvp24qu"

vault_token=$(curl -fsS \
  -H "Metadata: true" \
  --get \
  --data-urlencode "api-version=2018-02-01" \
  --data-urlencode "resource=https://vault.azure.net" \
  "http://169.254.169.254/metadata/identity/oauth2/token" |
  python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')

vault_list_code=$(curl -sS \
  -o /tmp/vault-list-response.txt \
  -w "%{http_code}" \
  -X GET "https://${keyvault_name}.vault.azure.net/secrets?api-version=7.4" \
  -H "Authorization: Bearer $vault_token")

echo "Key Vault secret-list status: $vault_list_code"