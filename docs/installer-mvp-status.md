# EHPanel Web Node Installer MVP Status

## Validated on staging

- AlmaLinux 10 base provisioning.
- Nginx public HTTP/HTTPS entrypoint.
- Let's Encrypt certificate for `web-01.theflakito.com`.
- Apache private backend on `127.0.0.1:8080`.
- PHP-FPM probe behind Nginx and Apache.
- MariaDB local-only service.
- PostgreSQL local-only service.
- Valkey local-only service.
- PowerDNS authoritative DNS with MariaDB backend and local API.
- Postfix SMTP base with Rspamd milter.
- Dovecot IMAP/LMTP base.
- Rspamd local workers and controller.
- Firewalld public/private port profile.
- Security baseline: SSH drop-in, fail2ban and auditd.
- Cgroups v2 base slices for panel and tenant workloads.
- User/group disk quotas on the root filesystem.
- Composer for PHP/Laravel app workflows.
- Node.js/npm runtime for Node app workflows.
- EHPanel Go agent installed as `ehagent-web`.
- End-to-end validation playbook at `playbooks/validate.yml`.

## Runbook

Provision full staging web node:

```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/web-node.yml -u root --ask-pass
```

Validate full staging web node:

```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/validate.yml -u root --ask-pass
```

## Pending after EHPanel Web orchestration starts

- Replace probe pages with real site/account provisioning.
- Build API commands from EHPanel Web to agent jobs.
- Create Linux hosting accounts with isolated users and home directories.
- Apply cgroups v2 limits per account from EHPanel Web plans.
- Apply disk quotas per account from EHPanel Web plans.
- Generate Nginx/Apache vhosts per domain.
- Generate PHP-FPM pools per account/version.
- Support multiple PHP versions through Remi after AlmaLinux 10 compatibility is verified.
- Create MariaDB/PostgreSQL databases and users per client.
- Create PowerDNS zones/records from panel actions.
- Complete mailbox/domain management from final client UI.
- Expose DKIM generation and DNS publication in EHPanel Web.
- Replace temporary TLS mail certs with per-node or per-mail-domain certificates.
- Add Certbot issuance per hosted domain.
- Add FTP/SFTP account management.
- Add app installers for WordPress, PHP apps, Django, Node.js, Python and Git deploys.
- Add backup system and restore workflow.
- Add ModSecurity or equivalent WAF after vhost provisioning is stable.
- Add OpenLiteSpeed as optional web engine after Nginx + Apache MVP is stable.
- Add production inventory with SSH keys and encrypted vaults.
- Add CI validation for Ansible syntax/lint.
