#!/bin/sh
. /etc/araneae/araneae.env
cat <<STATUS
Araneae OS status
Hostname: $(uci -q get system.@system[0].hostname)
LAN: ${ARANAE_LAN_IP}
WireGuard: ${ARANAE_WG_SERVER_IP}:${ARANAE_WG_PORT}/udp
Mattermost: http://${ARANAE_WG_SERVER_IP}:${ARANAE_MATTERMOST_PORT}
Server public key: $(cat /etc/wireguard/server_public.key 2>/dev/null || echo not-generated-yet)

Docker containers:
STATUS
docker ps --format '  {{.Names}}  {{.Status}}  {{.Ports}}' 2>/dev/null || echo '  Docker not ready.'
