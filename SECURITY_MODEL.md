# Security model — Araneae

This document describes **assets**, **adversaries**, **trust boundaries**, and **assumptions** for the **Araneae** project, aligned with the *Privacy is for the people* philosophy and the planned technical design (CM4, network, NAS/SSD, LiFePO4 UPS, Rust/C/Assembly, future OpenWrt base).

It is not a substitute for formal analysis for commercial certifications; it guides design, contribution review, and communication with users.

## Security objectives

| Objective | Meaning in Araneae |
|-----------|-------------------|
| **Confidentiality** | User traffic and data must not be exposed by hidden telemetry, undocumented services, or a default configuration that is “too open.” |
| **Integrity** | Firmware, configuration, and system images must be buildable and verifiable; updates must be understandable to the operator. |
| **Availability** | Internal UPS (LiFePO4, power path, BMS) and sound power practices aim for continuity; the device is still not immune to physical failure or DoS. |

## Primary assets

1. **Data at rest** — content on SSD/NAS (PCIe), possibly user-encrypted (not mandatory for the project, but relevant to threats).
2. **Data in transit** — WAN/LAN, VPN, Tor, proxy; keys and policies defined by the user.
3. **Credentials and policies** — SSH is allowed by philosophy of direct control; that requires **documented hardening** and secure defaults where possible.
4. **Firmware / OS integrity** — OpenWrt or equivalent image, boot chain, possible signatures (future).
5. **Hardware** — CM4, BCM54210PE PHY, KSZ9893 switch, MP1584 converters, UPS chain, USB-C/A, HDMI, **EXT_GPIO** on the 26-pin header.

- **Inside the box:** everything running on the SoC and services chosen by the user is “trusted” only insofar as the **operator** trusts the image they installed and the configuration.
- **Outside the box:** WAN and clients are untrusted by default.

## Adversaries considered

1. **Remote (network)** — exploitation of exposed services, drive-by on the LAN, WAN MITM if the user does not use adequate protections.
2. **Local (internal network)** — compromised LAN devices trying to escalate or reach NAS/services.
3. **Physical, brief access** — USB media insertion, connection to a debug header (SWD), attempts to read storage.
4. **Physical, prolonged possession** — SSD extraction, PCB tampering; mitigation is usually **encryption** + operational policy, not firmware alone.
5. **Supply chain** — components, toolchain, chip firmware blobs (PHY, switch, etc.). The project seeks **maximum openness**, but some elements may remain proprietary in practice; that must be **documented honestly**.

## Privacy and telemetry

- **Product requirement:** **zero undocumented telemetry.** Any diagnostic channel must be **explicit**, **local**, or **opt-in**.
- **Security implication:** no “phone home” reduces surface and metadata leakage, but **does not** remove other vectors (e.g. a misconfigured self-hosted service).

## Hardware — security implications

| Component | Security / trust note |
|-----------|----------------------|
| **CM4 + eMMC/SD** | Boot vector; protect updates and, if desired, secure boot (future policy to document). |
| **PCIe SSD** | Sensitive data; user encryption recommended for physical threat. |
| **USB-C / USB-A** | Classic attack surface; ESD and mount/automount policy should be conservative by default. |
| **Exposed GPIO / I2C** | Headers improve hackability; they also widen surface if an attacker has physical access. |
| **UPS / I2C (e.g. LTC4015)** | **Local** battery telemetry is desirable for operation; it must not become network exfiltration without consent. |
| **KSZ9893 / MDIO-SPI** | Traffic monitoring is a **feature**; it must be under operator control, not hidden third parties. |

## Software — stack and surface

- **Rust** — services and control (incl. GPIO); reduces some memory-error classes, but logic can still fail.
- **C / Assembly** — low-level integration; careful review; avoid unnecessary `unsafe` in Rust wrapping FFI.
- **OpenWrt (planned)** — defaults, packages, and init must respect Araneae philosophy; contributions that add analytics or undocumented services are **misaligned**.

## What Araneae does not guarantee

- Protection against an **operator** who disables the firewall or exposes insecure services.
- Resistance to **lab-grade physical attacks** without extra measures (mesh, tamper evidence, encryption).
- Security of **third-party applications** (self-hosted — e.g. RustDesk, VPN) beyond what the project documents as integration.

## Relationship to [SECURITY.md](./SECURITY.md)

Vulnerabilities that break the promises above (e.g. hidden telemetry, backdoor, RCE in documented default configuration) should be reported through the security policy. Improvements to this model are welcome via contributions that stay clear and honest about limitations.

## Summary

Araneae combines **verifiable open hardware**, **auditable software**, and **privacy by design**. Effective security depends on **conscious configuration**, **updates**, and — when physical threat matters — **encryption and operational policies** chosen by the user.
