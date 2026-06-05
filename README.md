# EHPanel-Ansible

Playbooks y roles para aprovisionar nodos AlmaLinux 10 con el stack completo de EHPanel Web.

**Estado**: instalador MVP para nodos web AlmaLinux 10. Los roles principales de runtime ya estan implementados; algunos roles de hardening/aislamiento siguen como stubs.

## Requisitos

```bash
pip install ansible>=2.17
ansible-galaxy collection install -r requirements.yml
# o: make deps
```

## Dry-run (--check)

```bash
# Dry-run completo con diff de cada cambio
ansible-playbook -i inventories/staging/hosts.yml \
  playbooks/web-node.yml \
  --check --diff \
  --ask-vault-pass

# Dry-run solo del rol common
ansible-playbook -i inventories/staging/hosts.yml \
  playbooks/web-node.yml \
  --tags common \
  --check --diff \
  --ask-vault-pass

# Validar estado sin cambios
ansible-playbook -i inventories/staging/hosts.yml \
  playbooks/validate.yml \
  --ask-vault-pass
```

## Atajos con Make

```bash
make deps                  # Instalar colecciones de Galaxy
make lint                  # ansible-lint en todos los playbooks
make staging-web-check     # Dry-run staging
make staging-web           # Aplicar en staging
make validate-staging      # Validar staging sin cambios
make prod-web-check        # Dry-run production
```

## Vault

Los archivos `vault.yml` reales no se versionan. Usa los `vault.example.yml`
como plantilla, copia el archivo a `vault.yml`, completa los valores reales y
cifralo antes del primer uso:

```bash
cp inventories/staging/group_vars/web_nodes/vault.example.yml inventories/staging/group_vars/web_nodes/vault.yml
ansible-vault encrypt inventories/staging/group_vars/web_nodes/vault.yml
ansible-vault edit inventories/staging/group_vars/web_nodes/vault.yml

ansible-playbook ... --ask-vault-pass
# o con archivo de contrasena, sin commitearlo:
ansible-playbook ... --vault-password-file .vault_pass
```

Nunca subir `vault.yml`, `.vault_pass`, llaves SSH, `.env` ni archivos generados
con secretos. `.gitignore` deja fuera esos archivos y versiona solo
`vault.example.yml`.

## Estructura de roles

| # | Rol | Estado | Proposito |
|---|-----|--------|-----------|
| 01 | `common` | Implementado | Base: paquetes, timezone, chrony, usuarios, dirs, sysctl, limits |
| 02 | `security-baseline` | Stub | Hardening: SELinux, SSH, fail2ban, auditd |
| 03 | `cgroups` | Stub | cgroups v2 slices por tenant |
| 04 | `disk-quotas` | Stub | Cuotas de disco por usuario/proyecto |
| 05 | `firewall` | Stub | firewalld + nftables |
| 06 | `nginx` | Implementado | Nginx reverse proxy y vhosts |
| 07 | `apache` | Implementado | Apache httpd en 127.0.0.1:8080 |
| 08 | `php` | Implementado | PHP-FPM + Composer |
| 09 | `nodejs` | Implementado | Node.js/npm + build tools |
| 10 | `mariadb` | Implementado | MariaDB solo localhost |
| 11 | `postgresql` | Implementado | PostgreSQL solo localhost |
| 12 | `valkey` | Implementado | Valkey compatible con protocolo Redis, solo localhost |
| 13 | `powerdns` | Implementado | PowerDNS Authoritative |
| 14 | `postfix` | Implementado | Postfix MTA |
| 15 | `dovecot` | Implementado | Dovecot IMAP/POP3 |
| 16 | `rspamd` | Implementado | Rspamd antispam + DKIM |
| 17 | `certbot` | Implementado | Certbot/ACME |
| 18 | `ehagent` | Implementado | EHPanel Web Agent |
| 19 | `hosting-runtime` | Implementado | Baseline por cuenta: snippets, SELinux, ACL WordPress |
| 20 | `ftp_server` | Implementado | FTP/FTPES con vsftpd, modo pasivo y firewalld |

Detalle del runtime de cuentas: [docs/hosting-runtime-baseline.md](docs/hosting-runtime-baseline.md)

## EHPanel Web local provisioning

El rol `ehpanel_web_panel` instala el helper local desde
`{{ ehpanel_web_panel_source_path }}/scripts/ehpanel-local-provision.py` hacia
`/usr/local/sbin/ehpanel-local-provision`. Ese helper es la fuente de verdad para
operaciones de runtime por cuenta: vhosts Nginx/OpenLiteSpeed, apps Git,
snippets avanzados y cambios de `document_root`.

Para que el cambio de raiz de sitio funcione de forma persistente, Ansible debe
mantener disponibles estos paths:

- `/home/<usuario>` para crear la nueva carpeta relativa.
- `/etc/nginx/conf.d` para reescribir el vhost del dominio.
- `/etc/nginx/ehpanel-apps` y `/etc/nginx/ehpanel-advanced` para snippets de apps y reglas avanzadas.
- `/etc/ehpanel/advanced` para configuraciones avanzadas por cuenta.
- `/usr/local/lsws/conf/vhosts` para actualizar el vhost OpenLiteSpeed.

Cuando EHPanel Web cambia la raiz de un dominio, encola `FILE_MKDIR` y
`PROVISION_OPENLITESPEED_HOSTING`/`PROVISION_HOSTING`; si el dominio ya tenia SSL
activo, tambien re-aplica el job SSL para que HTTP y HTTPS apunten al nuevo
`document_root`.

## Riesgos pendientes

- **R01**: PHP 7.4 no disponible en repos oficiales de AlmaLinux 10.
- **R08**: firewalld en RHEL 10 usa nftables exclusivamente; no usar iptables legacy.

Ver [docs/ehpanel-ansible-design.md](../docs/ehpanel-ansible-design.md) para el analisis completo.
