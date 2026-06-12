#!/usr/bin/env bash

set -euo pipefail

# -------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------

usage() {
  echo "Usage: $0 [version]"
  echo ""
  echo "  version  Optional. If omitted, fetches the latest from code.kimi.com."
  exit 1
}

get_sri_hash() {
  local hex_hash="$1"
  nix hash convert --hash-algo sha256 --to sri "$hex_hash"
}

# -------------------------------------------------------------------
# Parse arguments
# -------------------------------------------------------------------
version="${1:-}"

if [[ "$version" == "--help" || "$version" == "-h" ]]; then
  usage
fi

# -------------------------------------------------------------------
# Resolve version
# -------------------------------------------------------------------
if [[ -z "$version" ]]; then
  echo "Fetching latest version from https://code.kimi.com/kimi-code/latest ..."
  version=$(curl -fsSL "https://code.kimi.com/kimi-code/latest" | tr -d '[:space:]')
fi

if [[ -z "$version" ]]; then
  echo "Error: Could not resolve latest version."
  exit 1
fi

echo "------------------------------------------------"
echo "Target Version: $version"
echo "------------------------------------------------"

# -------------------------------------------------------------------
# Fetch manifest
# -------------------------------------------------------------------
manifest_url="https://code.kimi.com/kimi-code/binaries/${version}/manifest.json"
echo "Fetching manifest from ${manifest_url} ..."
manifest=$(curl -fsSL "$manifest_url")

if [[ -z "$manifest" ]]; then
  echo "Error: Failed to fetch manifest. Check if version '$version' exists."
  exit 1
fi

# -------------------------------------------------------------------
# Extract checksums from manifest
# -------------------------------------------------------------------
hash_x64=$(echo "$manifest" | jq -r '.platforms["linux-x64"].checksum')
hash_arm64=$(echo "$manifest" | jq -r '.platforms["linux-arm64"].checksum')

if [[ -z "$hash_x64" || "$hash_x64" == "null" ]]; then
  echo "Error: Could not find linux-x64 checksum in manifest."
  exit 1
fi

if [[ -z "$hash_arm64" || "$hash_arm64" == "null" ]]; then
  echo "Warning: Could not find linux-arm64 checksum in manifest. Using placeholder."
  hash_arm64_sri="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
else
  hash_arm64_sri=$(get_sri_hash "$hash_arm64")
fi

hash_x64_sri=$(get_sri_hash "$hash_x64")

echo "  x86_64-linux  hash: $hash_x64_sri"
echo "  aarch64-linux hash: $hash_arm64_sri"

# -------------------------------------------------------------------
# Update package.nix
# -------------------------------------------------------------------
target_file="package.nix"

if [[ ! -f "$target_file" ]]; then
  echo "Error: $target_file not found in current directory."
  exit 1
fi

echo "Updating $target_file ..."

temp_file=$(mktemp)

# Update version
sed "s|version = \".*\";|version = \"$version\";|" "$target_file" > "$temp_file"

# Update x86_64-linux hash (the one in the x86_64-linux block)
sed -i '/x86_64-linux/,/};/{s|hash = "sha256-.*";|hash = "'"$hash_x64_sri"'";|}' "$temp_file"

# Update aarch64-linux hash (the one in the aarch64-linux block)
sed -i '/aarch64-linux/,/};/{s|hash = "sha256-.*";|hash = "'"$hash_arm64_sri"'";|}' "$temp_file"

mv "$temp_file" "$target_file"

# -------------------------------------------------------------------
# Update version.json
# -------------------------------------------------------------------
echo "Updating version.json ..."
cat > "version.json" << EOF
{
  "version": "$version"
}
EOF

# -------------------------------------------------------------------
# Update README.md badge (if present)
# -------------------------------------------------------------------
if [[ -f "README.md" ]]; then
  echo "README.md found — badge should auto-update from version.json"
fi

echo "------------------------------------------------"
echo "Success! Updated to kimi-code version ${version}"
echo "------------------------------------------------"
