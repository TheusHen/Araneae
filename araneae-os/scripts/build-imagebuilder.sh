#!/usr/bin/env bash
set -euo pipefail

PROFILE_ENV="${1:-profiles/rpi4-cm4.env}"
if [[ ! -f "$PROFILE_ENV" ]]; then
  echo "Profile env not found: $PROFILE_ENV" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$PROFILE_ENV"

: "${OPENWRT_VERSION:?missing OPENWRT_VERSION}"
: "${OPENWRT_TARGET:?missing OPENWRT_TARGET}"
: "${OPENWRT_PROFILE:?missing OPENWRT_PROFILE}"
: "${OPENWRT_ROOT:?missing OPENWRT_ROOT}"
: "${PACKAGES_FILE:?missing PACKAGES_FILE}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
OVERLAY_DIR="$BUILD_DIR/files-overlay"
TARGET_DASH="${OPENWRT_TARGET//\//-}"
IMAGEBUILDER_NAME="openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET_DASH}.Linux-x86_64"
IMAGEBUILDER_ARCHIVE="${IMAGEBUILDER_NAME}.tar.zst"
IMAGEBUILDER_URL="${OPENWRT_ROOT}/${IMAGEBUILDER_ARCHIVE}"

mkdir -p "$BUILD_DIR" "$DIST_DIR"

if [[ ! -d "$BUILD_DIR/$IMAGEBUILDER_NAME" ]]; then
  if [[ ! -f "$BUILD_DIR/$IMAGEBUILDER_ARCHIVE" ]]; then
    echo "Downloading Image Builder: $IMAGEBUILDER_URL"
    curl -fL "$IMAGEBUILDER_URL" -o "$BUILD_DIR/$IMAGEBUILDER_ARCHIVE"
  fi
  echo "Extracting Image Builder..."
  tar --zstd -xf "$BUILD_DIR/$IMAGEBUILDER_ARCHIVE" -C "$BUILD_DIR"
fi

echo "Preparing overlay..."
rm -rf "$OVERLAY_DIR"
mkdir -p "$OVERLAY_DIR"
cp -a "$ROOT_DIR/files/." "$OVERLAY_DIR/"
mkdir -p "$OVERLAY_DIR/etc/araneae"
cat > "$OVERLAY_DIR/etc/araneae/araneae.env" <<ENVEOF
ARANAE_HOSTNAME="${ARANAE_HOSTNAME:-araneae}"
ARANAE_LAN_IP="${ARANAE_LAN_IP:-192.168.8.1}"
ARANAE_LAN_NETMASK="${ARANAE_LAN_NETMASK:-255.255.255.0}"
ARANAE_WG_SERVER_IP="${ARANAE_WG_SERVER_IP:-10.66.66.1}"
ARANAE_WG_CIDR="${ARANAE_WG_CIDR:-10.66.66.1/24}"
ARANAE_WG_PORT="${ARANAE_WG_PORT:-51820}"
ARANAE_MATTERMOST_PORT="${ARANAE_MATTERMOST_PORT:-8065}"
ENVEOF

chmod +x "$OVERLAY_DIR"/etc/uci-defaults/* || true
chmod +x "$OVERLAY_DIR"/etc/init.d/* || true
chmod +x "$OVERLAY_DIR"/etc/araneae/scripts/* || true

read_packages() {
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$ROOT_DIR/$PACKAGES_FILE" | tr '\n' ' '
}

PACKAGES="$(read_packages)"
case "${SSH_SERVER:-dropbear}" in
  openssh)
    PACKAGES="$PACKAGES -dropbear openssh-server openssh-sftp-server"
    ;;
  dropbear|"")
    # OpenWrt includes dropbear by default.
    ;;
  *)
    echo "Unknown SSH_SERVER=${SSH_SERVER}. Use dropbear or openssh." >&2
    exit 1
    ;;
esac

cd "$BUILD_DIR/$IMAGEBUILDER_NAME"

echo "Building Araneae OS image for profile ${OPENWRT_PROFILE}..."
echo "Package count: $(wc -w <<< "$PACKAGES")"
make image PROFILE="$OPENWRT_PROFILE" PACKAGES="$PACKAGES" FILES="$OVERLAY_DIR"

OUT_DIR="bin/targets/${OPENWRT_TARGET}"
if [[ -d "$OUT_DIR" ]]; then
  mkdir -p "$DIST_DIR"
  find "$OUT_DIR" -maxdepth 1 -type f \( -name '*.img.gz' -o -name '*.manifest' -o -name '*.buildinfo' -o -name '*.json' \) -exec cp -v {} "$DIST_DIR/" \;
fi

echo
printf 'Done. Images copied to: %s\n' "$DIST_DIR"
echo "Flash the factory/ext4/sdcard image appropriate for your CM4 storage target."
