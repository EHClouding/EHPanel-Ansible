# EHPanel Web Node MVP Baseline

This document defines the minimum technical baseline a web node must pass before it is considered reusable for EHPanel Web staging or as a template for future Radio, Video and SRT installers.

## Scope

The baseline validates the node operating system, public network surface, web stack, mail stack, DNS stack, resource controls, cache, agent connectivity and core security controls.

It does not validate final customer UI flows. Those belong to EHPanel Web once the interface kit is selected.

## Target Platform

- OS: AlmaLinux 10.
- Public entrypoint: Nginx on ports 80 and 443.
- Private backend web engine: Apache on `127.0.0.1:8080`.
- Optional backend web engine: OpenLiteSpeed on `127.0.0.1:8088`.
- Runtime: PHP-FPM, Composer, Node.js and npm.
- Databases: MariaDB and PostgreSQL bound to localhost.
- Cache: Valkey bound to localhost.
- DNS: PowerDNS authoritative on port 53, API on localhost.
- Mail: Postfix, Dovecot and Rspamd.
- Agent: `ehagent-web` connected to EHPanel Web through WSS.

## Provisioning Command

```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/web-node.yml -u root --ask-pass --diff
```

Production must use SSH keys and encrypted vault values instead of root/password access.

## Validation Command

```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/validate.yml -u root --ask-pass
```

The validation playbook is read-only. It must not mutate the node.

## Baseline Checks

- AlmaLinux major version is 10.
- Timezone matches inventory.
- NTP is synchronized.
- EHPanel directories exist.
- cgroups v2 is active and required controllers exist.
- EHPanel systemd slices are loaded and active.
- User and group quotas are active.
- SSH effective config matches inventory variables.
- Fail2ban has the `sshd` jail active.
- Auditd is enabled.
- Required services are active.
- Private services are bound to localhost.
- OpenLiteSpeed WebAdmin, when installed, is bound to `127.0.0.1:7080`.
- Public firewalld surface contains only expected services and ports.
- Nginx config is valid.
- HTTP/HTTPS probes respond.
- Composer, Node.js and npm are installed.
- Certbot has a valid certificate for the primary node domain.
- MariaDB, PostgreSQL and Valkey respond locally.
- PowerDNS can list zones.
- Postfix, Dovecot and Rspamd validate config.
- Agent binary and config exist.

## Current Staging Exceptions

Staging keeps temporary root/password SSH access:

```yaml
security_ssh_permit_root_login: "yes"
security_ssh_password_auth: "yes"
security_selinux_state: permissive
```

These are staging-only overrides. Production defaults are stricter:

```yaml
security_ssh_permit_root_login: "no"
security_ssh_password_auth: "no"
security_selinux_state: enforcing
```

## Production Gate

Before using this baseline on production:

- Replace root/password SSH with SSH keys.
- Encrypt all vault files.
- Confirm production domains and certbot email.
- Confirm reverse DNS for mail node IPs.
- Run the full validation playbook after provisioning.
- Keep a fresh server snapshot before the first production run.

## OpenLiteSpeed Notes

The `openlitespeed` role installs the official LiteSpeed repository,
`openlitespeed`, and `lsphp84` packages. Nginx remains the public edge for
HTTP, HTTPS, ACME challenges and Cloudflare-facing traffic. OpenLiteSpeed stays
private behind Nginx and is selected per account by the EHPanel agent job
`provision_openlitespeed_hosting`.

## Reuse Pattern For Other Panels

Use the same structure for EHPanel Radio, Video and SRT:

- Keep Ansible roles idempotent.
- Keep node agents service-specific.
- Keep panel-to-agent contracts documented.
- Validate with a read-only playbook before UI work.
- Commit and push every completed technical block.
- Deploy through Server0 once the panel deploy flow is active.
