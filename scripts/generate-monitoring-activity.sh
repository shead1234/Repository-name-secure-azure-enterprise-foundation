#!/bin/sh

storage_name="stnrgsefrksl2exvp24qu"
keyvault_name="kv-nrg-sef-rksl2exvp24qu"
container_name="appdata"
blob_name="logging-test-$(date +%s).txt"

blob_url="https://${storage_name}.blob.core.windows.net/${container_name}/${blob_name}"
vault_url="https://${keyvault_name}.vault.azure.net/secrets/logging-test?api-version=7.4"

get_token() {
  curl -fsS \
    -H "Metadata: true" \
    --get \
    --data-urlencode "api-version=2018-02-01" \
    --data-urlencode "resource=$1" \
    "http://169.254.169.254/metadata/identity/oauth2/token" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])'
}

storage_token=$(get_token "https://storage.azure.com/")
storage_token_status=$?

vault_token=$(get_token "https://vault.azure.net")
vault_token_status=$?

if [ "$storage_token_status" -ne 0 ] || [ -z "$storage_token" ]; then
  echo "Storage token request failed"
  exit 1
fi

if [ "$vault_token_status" -ne 0 ] || [ -z "$vault_token" ]; then
  echo "Key Vault token request failed"
  exit 1
fi

printf 'Northstar managed identity logging test\n' > /tmp/logging-test.txt
content_length=$(wc -c < /tmp/logging-test.txt | tr -d ' ')

put_code=$(curl -sS -o /tmp/blob-put-response.txt -w "%{http_code}" \
  -X PUT "$blob_url" \
  -H "Authorization: Bearer $storage_token" \
  -H "x-ms-date: $(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S GMT")" \
  -H "x-ms-version: 2023-11-03" \
  -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Length: $content_length" \
  --data-binary @/tmp/logging-test.txt)

get_code=$(curl -sS -o /tmp/blob-get-response.txt -w "%{http_code}" \
  -X GET "$blob_url" \
  -H "Authorization: Bearer $storage_token" \
  -H "x-ms-date: $(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S GMT")" \
  -H "x-ms-version: 2023-11-03")

delete_code=$(curl -sS -o /tmp/blob-delete-response.txt -w "%{http_code}" \
  -X DELETE "$blob_url" \
  -H "Authorization: Bearer $storage_token" \
  -H "x-ms-date: $(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S GMT")" \
  -H "x-ms-version: 2023-11-03")

vault_code=$(curl -sS -o /tmp/vault-response.txt -w "%{http_code}" \
  -X GET "$vault_url" \
  -H "Authorization: Bearer $vault_token")

echo "Storage upload status: $put_code"
echo "Storage download status: $get_code"
echo "Storage delete status: $delete_code"
echo "Key Vault audit-test status: $vault_code"