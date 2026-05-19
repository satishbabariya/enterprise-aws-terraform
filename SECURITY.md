# Security Policy

## Reporting a Vulnerability

If you discover a security issue in this template (a Terraform pattern that
weakens security posture, leaks credentials, or violates a compliance control
the template claims to enforce), please report it privately.

**Do not open a public GitHub issue.**

Email: themadengineer99@gmail.com

Include:
- A description of the issue
- The module/file/line affected
- Steps to reproduce
- Suggested remediation (if known)

You should receive an acknowledgement within 72 hours.

## Scope

In scope:
- All Terraform code under `modules/`, `medium/`, `large/`, `bootstrap/`
- IAM/SCP policies that grant more access than documented
- Encryption gaps (missing KMS, weak ciphers, plaintext storage)
- Network exposure (unintended public access, missing TLS)
- Compliance regressions vs. `docs/compliance-matrix.md`
- GitHub Actions workflows that leak secrets or allow unauthorized apply

Out of scope:
- AWS service vulnerabilities (report to AWS via aws-security@amazon.com)
- Issues in reference repos under `refrences/`
- Theoretical attacks requiring management-account compromise (that account
  is assumed to be the trust root)

## Disclosure Timeline

| Stage                        | Target     |
|------------------------------|------------|
| Acknowledge report           | 72 hours   |
| Triage + severity assessment | 7 days     |
| Fix in main                  | 30 days    |
| Public disclosure            | 90 days    |

Critical issues (CVSS >= 9) will be patched ASAP, not on the standard timeline.
