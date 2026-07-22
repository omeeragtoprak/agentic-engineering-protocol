# Security Policy

AEP is a set of markdown instructions, one POSIX shell hook, and templates — it
bundles no network services and phones home to nothing. The primary security
surfaces are:

- **The Stop hook** (`plugins/aep/scripts/verify-gate.sh`): runs your repo's
  `.claude/aep-check.sh`. It executes only what the *user's own repository*
  provides, in the user's own environment.
- **Skills/agents content**: plain instructions loaded into the agent's context.

## Reporting a vulnerability

If you find a way for a repository, a diff, or a crafted check script to abuse
the gate or the skills to exfiltrate data or execute unintended commands, please
report it privately via GitHub Security Advisories
(Security tab → "Report a vulnerability") rather than a public issue.

You can expect an acknowledgement within a few days. Fixes ship as a patch
release with a CHANGELOG entry crediting the reporter (unless you prefer
otherwise).
