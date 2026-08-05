#!/usr/bin/env bash

set -u

key_vault_name="${1:?Key Vault name is required}"
storage_account="${2:?Storage account name is required}"
container_name="${3:?Container name is required}"

failures=0
blob_created=0

kv_body="$(mktemp)"
put_body="$(mktemp)"
get_body="$(mktemp)"
delete_body="$(mktemp)"

cleanup_files() {
  rm -f "$kv_body" "$put_body" "$get_body" "$delete_body"
}

trap cleanup_files EXIT

get_managed_identity_token() {
  local encoded_resource="$1"
  local response

  response="$(
    curl \
      --fail \
      --silent \
      --show-error \
      --connect-timeout 10 \
      --max-time 30 \
      -H 'Metadata:true' \
      "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${encoded_resource}"
  )" || return 1

  printf '%s' "$response" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["access_token"])'
}

echo "============================================================"
echo "MANAGED-IDENTITY END-TO-END VALIDATION"
echo "============================================================"

echo
echo "Acquiring Key Vault token..."

kv_token="$(
  get_managed_identity_token 'https%3A%2F%2Fvault.azure.net'
)" || {
  echo "KEY VAULT TOKEN: FAILED"
  exit 1
}

if [ -n "$kv_token" ]; then
  echo "KEY VAULT TOKEN: PASSED"
else
  echo "KEY VAULT TOKEN: FAILED"
  exit 1
fi

echo
echo "Testing Key Vault metadata access..."

kv_http="$(
  curl \
    --silent \
    --show-error \
    --output "$kv_body" \
    --write-out '%{http_code}' \
    --connect-timeout 15 \
    --max-time 45 \
    -H "Authorization: Bearer $kv_token" \
    "https://${key_vault_name}.vault.azure.net/secrets?api-version=7.4"
)"

if [ "$kv_http" = "200" ]; then
  secret_count="$(
    python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(len(data.get("value", [])))
' < "$kv_body"
  )"

  echo "KEY VAULT ACCESS: PASSED (HTTP 200)"
  echo "Secret metadata records visible: $secret_count"
else
  echo "KEY VAULT ACCESS: FAILED (HTTP $kv_http)"
  head -c 1000 "$kv_body"
  echo
  failures=$((failures + 1))
fi

echo
echo "Acquiring Azure Storage token..."

storage_token="$(
  get_managed_identity_token 'https%3A%2F%2Fstorage.azure.com%2F'
)" || {
  echo "STORAGE TOKEN: FAILED"
  exit 1
}

if [ -n "$storage_token" ]; then
  echo "STORAGE TOKEN: PASSED"
else
  echo "STORAGE TOKEN: FAILED"
  exit 1
fi

blob_name="managed-identity-validation-$(date -u +%s).txt"
blob_url="https://${storage_account}.blob.core.windows.net/${container_name}/${blob_name}"
blob_content="Managed identity access validated at $(date -u '+%Y-%m-%dT%H:%M:%SZ')."

echo
echo "Testing Storage blob creation..."

request_date="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

put_http="$(
  curl \
    --silent \
    --show-error \
    --output "$put_body" \
    --write-out '%{http_code}' \
    --request PUT \
    --connect-timeout 15 \
    --max-time 45 \
    -H "Authorization: Bearer $storage_token" \
    -H "x-ms-date: $request_date" \
    -H 'x-ms-version: 2023-11-03' \
    -H 'x-ms-blob-type: BlockBlob' \
    -H 'Content-Type: text/plain' \
    --data-binary "$blob_content" \
    "$blob_url"
)"

if [ "$put_http" = "201" ]; then
  echo "STORAGE BLOB CREATE: PASSED (HTTP 201)"
  echo "Temporary blob: $blob_name"
  blob_created=1
else
  echo "STORAGE BLOB CREATE: FAILED (HTTP $put_http)"
  head -c 1000 "$put_body"
  echo
  failures=$((failures + 1))
fi

if [ "$blob_created" -eq 1 ]; then
  echo
  echo "Testing Storage blob read..."

  request_date="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

  get_http="$(
    curl \
      --silent \
      --show-error \
      --output "$get_body" \
      --write-out '%{http_code}' \
      --connect-timeout 15 \
      --max-time 45 \
      -H "Authorization: Bearer $storage_token" \
      -H "x-ms-date: $request_date" \
      -H 'x-ms-version: 2023-11-03' \
      "$blob_url"
  )"

  downloaded_content="$(cat "$get_body")"

  if (
    [ "$get_http" = "200" ] &&
    [ "$downloaded_content" = "$blob_content" ]
  ); then
    echo "STORAGE BLOB READ: PASSED (HTTP 200)"
    echo "Downloaded content matched the uploaded content."
  else
    echo "STORAGE BLOB READ: FAILED (HTTP $get_http)"
    failures=$((failures + 1))
  fi

  echo
  echo "Deleting temporary validation blob..."

  request_date="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

  delete_http="$(
    curl \
      --silent \
      --show-error \
      --output "$delete_body" \
      --write-out '%{http_code}' \
      --request DELETE \
      --connect-timeout 15 \
      --max-time 45 \
      -H "Authorization: Bearer $storage_token" \
      -H "x-ms-date: $request_date" \
      -H 'x-ms-version: 2023-11-03' \
      "$blob_url"
  )"

  if [ "$delete_http" = "202" ]; then
    echo "STORAGE BLOB CLEANUP: PASSED (HTTP 202)"
  else
    echo "STORAGE BLOB CLEANUP: FAILED (HTTP $delete_http)"
    head -c 1000 "$delete_body"
    echo
    failures=$((failures + 1))
  fi
fi

echo

if [ "$failures" -eq 0 ]; then
  echo "MANAGED-IDENTITY ACCESS PATH: PASSED"
  echo "The VM accessed Key Vault and Storage without credentials, keys, or SAS tokens."
  exit 0
fi

echo "MANAGED-IDENTITY ACCESS PATH: FAILED"
echo "Failed checks: $failures"
exit 1