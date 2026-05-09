# Contributing to Araneae

Thank you for considering a contribution to **Araneae** — an *open hardware* + *open software* router focused on **real privacy**, **no vendor lock-in**, and **full hackability**, able to replace home infrastructure (router, NAS, and services).

> **Philosophy:** *Your network should answer to you, not report on you.*  
> **Software license:** [UNLICENSE](./UNLICENSE) (public domain), unless a submodule or folder states its own license explicitly.

This document summarizes expectations, scope, and how to send contributions aligned with the project vision.

## Principles that guide every contribution

1. **Zero telemetry by default** — no hidden collection, phone-home, or undocumented analytics. If something needs diagnostics, it must be **opt-in**, local, and documented.
2. **Verifiability** — schematics, firmware, and build policies should allow third-party audit where feasible.
3. **No lock-in** — prefer open standards and documented interfaces (GPIO with the **EXT_GPIO** convention, not opaque 1:1 mapping to the CM4 without explanation).
4. **Security and clarity** — changes affecting power, PCIe, USB-C (sink/source), or networking should include enough context for review (datasheets, layout notes, risks).

## What you can contribute

- **Hardware:** schematics, PCB notes, BOM, rail verification (12 V, 5 V, 3.3 V, 1.8 V), ESD/TVS protection, CM4 / KSZ9893 / PCIe SSD / LiFePO4 UPS integration.
- **Software / firmware:** Rust (control, services, GPIO), C (low level / hardware), Assembly (critical paths), future integration with **OpenWrt** as the system base.
- **Documentation:** assembly guides, operational security, self-hosting (e.g. RustDesk), VPN, Tor, proxy, firewall — always transparent about what runs where and what leaves the network.
- **Tests and automation:** existing CI (CodeQL, SBOM, Scorecard) should keep passing; new checks are welcome if they are reproducible and do not require unnecessary secrets.

## Branch naming for pull requests

Branches you use for pull requests **must** start with the `dev/` prefix. You may choose either pattern:

- **`dev/{feature}`** — short description of what you are implementing (e.g. `dev/usb-power-path-docs`).
- **`dev/{username}/{feature}`** — the same, grouped under your username or handle (e.g. `dev/jane/ci-cache`).

Use lowercase, hyphens instead of spaces, and keep names concise but recognizable.

## Before opening a pull request

1. Look for existing issues or discussions to avoid duplicate work.
2. For large changes, open an issue first (brief RFC): goal, impact on hardware/software, security or privacy risks.
3. Keep the PR **focused** — one topic per PR makes review and bisect easier.
4. Describe **what** changed and **why**, with references (datasheet section, CVE, RFC) when relevant.

## Code and project standards

- Follow the style already in the repository (formatting, names, modules).
- **Rust:** idiomatic code, errors handled explicitly; avoid `unwrap` on paths that can fail in production without documentation.
- **C / Assembly:** comments where timing or hardware require them; avoid undocumented “magic.”
- **Config and scripts:** no keys or tokens; use environment variables or documented placeholders.
- **Privacy:** do not introduce telemetry endpoints, analytics, or silent updates without documented consent.

## Hardware — critical areas already on the roadmap

Expect stricter review when touching these topics:

| Area | Notes |
|------|--------|
| **Power** | Correct rail distribution; modern buck (**MP1584** instead of LM2596); barrel vs battery path (PMOS Q1, charge/protection NMOS); power path (**LTC4412**), charger (**LTC4015**), BMS (**ISL94202**), **LiFePO4 4S** cells. |
| **KSZ9893** | **AVDDL / AVDDH / DVDDL / VDDIO** supplies, bypass, boot straps. |
| **SSD (PCIe)** | Stable clock (dedicated 32.768 kHz oscillator, **3V3_SSD** rail); **PERST#**, **CLKREQ#**, **SUSCLK**; clean power (load switch, ferrite bead). |
| **USB-C** | Correct sink/source role; **5.1 kΩ** CC resistors; ESD. |
| **Protection** | ESD on USB, HDMI, Ethernet; polyfuse; TVS under review for power headers. |

## Commits and messages

- Clear messages in English (stay consistent within a PR).
- Reference issues when applicable: `Fixes #123`.

## Code of conduct

Participation is subject to [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). Respectful behavior is not optional.

## Questions

If something is not documented here, open an issue with an appropriate label (when available) or ask in the discussion linked to the PR. Contributions that strengthen **privacy**, **transparency**, and **hackability** are especially welcome.
