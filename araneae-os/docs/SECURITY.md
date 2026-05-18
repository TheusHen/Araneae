# Araneae OS security notes

## Defaults included

- WireGuard is the only WAN-exposed service by default.
- Mattermost binds to the VPN IP only.
- Firewall rejects Mattermost from LAN and WAN.
- PostgreSQL is not published to host ports.
- Random database password generated on first boot.
- Docker data lives under `/srv/docker` when possible.

## Do before real-world deployment

- Set a strong root password immediately after first boot.
- Replace self-signed LuCI HTTPS certs if needed.
- Back up `/etc/wireguard`, `/etc/config/network`, and `/srv/araneae/mattermost`.
- Keep Mattermost and Docker images updated.
- Pin Mattermost image versions instead of floating tags.
- Add periodic offline backups.
- Consider a reverse proxy + HTTPS inside VPN for Mattermost.

## Do not do

- Do not expose Mattermost directly to WAN.
- Do not auto-format NVMe on devices that might contain data.
- Do not use this as production firmware until your board-specific DTS and firewall rules are tested.
