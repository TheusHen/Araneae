# Araneae OS Starter Kit

Custom OpenWrt image scaffold for a Raspberry Pi Compute Module 4 / Raspberry Pi 4 router appliance with:

- LuCI + HTTPS
- WireGuard VPN generated on first boot
- Mattermost local chat server reachable only from WireGuard
- Docker + Docker Compose
- NVMe/USB/storage packages
- Samba/NFS packages
- collectd monitoring + LuCI statistics
- safe first-boot provisioning scripts

This repo is a starter kit, not a finished commercial firmware. It is designed to get your first Araneae OS image building quickly, then let you evolve it into a full OpenWrt fork later.

---

## Target

Default target profile:

```text
OpenWrt: 24.10.6
Target: bcm27xx/bcm2711
Profile: rpi-4
Package manager: opkg
Hardware: Raspberry Pi CM4 / Raspberry Pi 4 class boards
Rootfs partition: 1024 MB
```

Why 24.10.x? Your current flow uses `opkg`. OpenWrt 25.x/snapshot branches may use different packaging behavior, so keep a separate branch when migrating.

The image uses a larger rootfs partition than OpenWrt's small default because LuCI, Docker, storage packages, and Mattermost support do not fit reliably in the default Raspberry Pi image size.

---

## Build

On Linux or WSL Ubuntu:

```bash
sudo apt update
sudo apt install -y build-essential curl file gawk gettext git libncurses-dev libssl-dev python3 rsync unzip wget zstd

cd araneae-os-starter
./scripts/build-imagebuilder.sh profiles/rpi4-cm4.env
```

The resulting images are copied to:

```text
dist/
```

Flash the appropriate `.img.gz` to SD/eMMC/NVMe using Balena Etcher, Raspberry Pi Imager, or `dd`.

---

## First boot behavior

On first boot, Araneae OS will:

1. Set hostname to `araneae`.
2. Set LAN IP to `192.168.8.1`.
3. Generate WireGuard server keys.
4. Create interface `wg0` at `10.66.66.1/24`.
5. Open UDP `51820` from WAN for WireGuard.
6. Bind Mattermost only to `10.66.66.1:8065`.
7. Block Mattermost access from WAN and LAN.
8. Start Docker and deploy Mattermost + PostgreSQL.

Mattermost Docker images are pulled on first boot. That means the router needs working internet once for the first deployment, unless you later add offline Docker image preloading.

---

## Access

After flashing:

```text
LuCI: https://192.168.8.1
SSH:  ssh root@192.168.8.1
```

Check status:

```sh
/etc/araneae/scripts/status.sh
```

Create a WireGuard peer:

```sh
/etc/araneae/scripts/create-wg-peer.sh phone 10.66.66.2 YOUR_PUBLIC_IP_OR_DDNS
```

Then copy the generated config from:

```text
/etc/araneae/wireguard/peer-phone.conf
```

After connecting to the VPN, open:

```text
http://10.66.66.1:8065
```

---

## Mattermost security model

Mattermost is not exposed on WAN. It is published only on the WireGuard server IP:

```yaml
ports:
  - "10.66.66.1:8065:8065"
```

Firewall rules also block direct LAN/WAN access to port `8065`.

For production, add:

- HTTPS reverse proxy inside the VPN
- pinned Mattermost version updates
- backups for `/srv/araneae/mattermost/volumes`
- external SMTP if you need email invites/password reset
- a private DNS name, for example `chat.araneae.lan`

---

## NVMe behavior

This starter kit is safe by default: it does **not** automatically wipe or format NVMe drives.

If `/dev/nvme0n1p1` already has a filesystem, it tries to mount it at:

```text
/srv
```

If you intentionally want first boot to format `/dev/nvme0n1`, create this marker before building the image:

```text
files/etc/araneae/allow-auto-format-nvme
```

Only do that on blank/test devices.

---

## KSZ9893 / KSZ9896 note

The KSZ switch layer is not fully solved by packages alone. For real hardware you will likely need:

- correct device tree / DT overlay
- DSA configuration, not old `swconfig`, on modern OpenWrt
- the correct Microchip KSZ driver for your kernel/target
- board-specific RGMII/RMII/SPI/I2C reset and interrupt lines

Use Image Builder for the first Araneae OS prototype. Use full OpenWrt buildroot when adding the final KSZ9893 hardware layer.

---

## Repo layout

```text
araneae-os-starter/
├── files/                         # Firmware overlay copied into the image
│   └── etc/
│       ├── araneae/               # Araneae scripts + Mattermost compose
│       ├── init.d/                # araneae-mattermost init service
│       ├── sysctl.d/              # sysctl hardening
│       └── uci-defaults/          # first boot provisioning
├── packages/                      # package lists
├── profiles/                      # target build envs
├── scripts/                       # build scripts
└── docs/                          # notes
```

---

## Next steps for a real Araneae OS

1. Add your CM4 carrier board DTS/DTBO.
2. Confirm KSZ9893 driver path and port naming.
3. Add `luci-app-araneae` for your own dashboard.
4. Add backup/restore for WireGuard peers and Mattermost volumes.
5. Add signed OTA sysupgrade metadata.
6. Add GitHub Actions build pipeline.
7. Split editions: `home`, `travel`, `enterprise`, `dev`.
