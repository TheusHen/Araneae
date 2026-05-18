#!/usr/bin/env bash
cat <<'NOTES'
For true Araneae OS kernel/device-tree work, use the full OpenWrt build system:

  git clone https://git.openwrt.org/openwrt/openwrt.git
  cd openwrt
  git checkout v24.10.6
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  make menuconfig

Then copy this project's files/ overlay into OpenWrt's root, add your KSZ9893
DTS patches under target/linux/bcm27xx/patches-6.6/ or a custom target, and build:

  make -j$(nproc)

Image Builder is enough for package + firstboot automation. Full buildroot is needed
for kernel config, custom DTS/DTBO, custom drivers, and official Araneae branding.
NOTES
