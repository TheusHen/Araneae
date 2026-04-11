# Security policy — Araneae

**Araneae** is an *open hardware* and *open software* project with an explicit commitment: **privacy for people**, **zero telemetry** by design, and **auditability**. This policy describes how to report vulnerabilities responsibly and what to expect in return.

## Versions and support

The project is evolving. Until there are stable, versioned releases:

- The repository’s default branch is considered the target for security reports.
- Third-party components (toolchains, OpenWrt when integrated, chip firmware) follow those projects’ policies.

When semantic releases exist, this section will be updated with a supported-version matrix.

## How to report a vulnerability

**Do not open a public issue** to disclose active exploits, proof-of-concept code, or details that would enable immediate abuse in production.

1. Use **GitHub Security Advisories** (Security → Report a vulnerability) if enabled on the repository, **or**
2. Email or use a private channel agreed with the maintainers (see repository or organization contacts).

When possible, include:

- Technical description of the issue and impact (confidentiality, integrity, availability).
- Minimal steps to reproduce or a **responsible** proof of concept.
- Affected hardware/software version, commit, or tag.
- Suggested mitigation (optional but very helpful).

## What to expect after you report

- **Acknowledgment** within a few business days (depending on maintainer availability).
- **Triage** of scope: product bug vs. user configuration vs. external dependency.
- **Coordinated disclosure**: preference to fix before public detail; timeline negotiable by severity and complexity.

The project **does not offer a bug bounty** by default unless explicitly announced later.

## Scope of this policy

**In scope (examples):**

- Vulnerabilities in Araneae firmware or services that allow unauthorized remote execution, firewall bypass, data leakage, or meaningful denial of service.
- Build-script issues that could compromise the supply chain (e.g. unverified binary downloads).
- Documentation errors that lead to **clear, reproducible** insecure configuration.

**Out of scope (examples):**

- Attacks that require unmitigated physical access to the device (the threat model treats physical access separately — see [SECURITY_MODEL.md](./SECURITY_MODEL.md)).
- Social engineering against users or maintainers.
- Spam or generic DoS against GitHub infrastructure.
- Issues in dependencies with no concrete exploitation path **through** Araneae (report to the upstream project as well).

## Philosophy and limitations

- Software is distributed under [UNLICENSE](./UNLICENSE) (“as is”). That does not reduce our interest in fixing good-faith security issues.
- **Privacy** does not mean no attack surface: it means **transparency** about what runs, **user control**, and **no hidden telemetry**.

## Coordinated disclosure

After a fix or documented mitigation is available, maintainers may publish an advisory with a CVE when appropriate. Researchers will be credited unless they explicitly request anonymity.

## Related links

- [SECURITY_MODEL.md](./SECURITY_MODEL.md) — threat model and trust assumptions.
- [CONTRIBUTING.md](./CONTRIBUTING.md) — how to contribute without regressing security or privacy.
