#!/usr/bin/env bash
set -euo pipefail
PROFILE_ENV="${1:-profiles/rpi4-cm4.env}"
source "$PROFILE_ENV"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKGS=$(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$ROOT_DIR/$PACKAGES_FILE")
TARGET_DASH="${OPENWRT_TARGET//\//-}"
PKG_INDEX_URL="${OPENWRT_ROOT}/packages/Packages.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL "$PKG_INDEX_URL" -o "$TMP/Packages.gz"
gzip -d "$TMP/Packages.gz"
missing=0
while read -r pkg; do
  [[ -z "$pkg" ]] && continue
  if ! grep -qx "Package: $pkg" "$TMP/Packages"; then
    echo "MISSING/NOT IN TARGET PACKAGES INDEX: $pkg"
    missing=$((missing+1))
  fi
done <<< "$PKGS"
if [[ "$missing" -gt 0 ]]; then
  echo "$missing package(s) were not found in target-specific packages index. Some may be in feeds/base indexes, but verify before building."
  exit 2
fi
echo "All packages found in target-specific package index."
