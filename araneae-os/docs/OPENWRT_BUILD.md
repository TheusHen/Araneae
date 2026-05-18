# Full OpenWrt buildroot path

Use Image Builder for package + overlay images.

Use full OpenWrt buildroot when you need:

- kernel config changes
- custom DTS/DTBO for your CM4 carrier board
- KSZ9893/KSZ9896 switch integration
- custom LuCI app package
- Araneae branding in base-files
- signed package feeds

Suggested flow:

```bash
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git checkout v24.10.6
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

Then copy `files/` from this starter kit into the OpenWrt tree root and add your board patches.

Build:

```bash
make -j$(nproc)
```
