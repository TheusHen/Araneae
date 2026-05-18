#!/bin/sh
set -eu
. /etc/araneae/araneae.env

NAME="${1:-phone}"
CLIENT_IP="${2:-10.66.66.2}"
ENDPOINT="${3:-YOUR_PUBLIC_IP_OR_DDNS}"
OUT_DIR="/etc/araneae/wireguard"
mkdir -p "$OUT_DIR"
chmod 700 "$OUT_DIR"
umask 077

SERVER_PUB="$(cat /etc/wireguard/server_public.key)"
CLIENT_PRIV="$(wg genkey)"
CLIENT_PUB="$(printf '%s' "$CLIENT_PRIV" | wg pubkey)"
PSK="$(wg genpsk)"

uci add network wireguard_wg0 >/dev/null
uci set network.@wireguard_wg0[-1].description="$NAME"
uci set network.@wireguard_wg0[-1].public_key="$CLIENT_PUB"
uci set network.@wireguard_wg0[-1].preshared_key="$PSK"
uci set network.@wireguard_wg0[-1].route_allowed_ips='1'
uci add_list network.@wireguard_wg0[-1].allowed_ips="${CLIENT_IP}/32"
uci commit network
/etc/init.d/network reload || true

CONF="$OUT_DIR/peer-${NAME}.conf"
cat > "$CONF" <<PEER
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = ${CLIENT_IP}/32
DNS = ${ARANAE_WG_SERVER_IP}

[Peer]
PublicKey = ${SERVER_PUB}
PresharedKey = ${PSK}
Endpoint = ${ENDPOINT}:${ARANAE_WG_PORT}
AllowedIPs = 10.66.66.0/24
PersistentKeepalive = 25
PEER

chmod 600 "$CONF"
echo "Created WireGuard peer: $NAME"
echo "Client config: $CONF"
echo "Mattermost URL after connecting: http://${ARANAE_WG_SERVER_IP}:${ARANAE_MATTERMOST_PORT}"
