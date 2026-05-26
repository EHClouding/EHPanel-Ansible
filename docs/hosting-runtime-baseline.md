# EHPanel Hosting Runtime Baseline

Este rol concentra los ajustes que deben existir antes de conectar un nodo web
al panel y al agente.

## Incluye

- Directorios base para snippets por cuenta en `/etc/ehpanel/software`.
- Directorio de logs por cuenta en `/var/log/ehpanel/hosting`.
- Paquetes base `acl` y `policycoreutils-python-utils` desde `common`.
- Contextos SELinux para:
  - contenido web de cuenta como `httpd_sys_content_t`;
  - `wp-content`, `wp-config.php` y `.htaccess` como `httpd_sys_rw_content_t`;
  - logs EHPanel como `httpd_log_t`.
- Boolean SELinux `httpd_enable_homedirs`.
- Helper `/usr/local/sbin/ehpanel-wordpress-permissions` para reparar permisos
  de WordPress de la misma forma que el agente.

## WordPress

WordPress necesita escribir normalmente en `wp-content`. Plugins de cache como
LiteSpeed Cache tambien necesitan tocar `wp-config.php` y `.htaccess`.

El helper aplica:

```bash
ehpanel-wordpress-permissions <usuario> <public_html>
```

Esto deja permisos Unix conservadores, ACL para los usuarios runtime PHP
configurados, y restaura contextos SELinux.

## Relacion con el agente

El agente sigue aplicando permisos por cuenta al instalar o reparar WordPress.
Ansible garantiza que el servidor nuevo ya tenga paquetes, SELinux y helper
listos, evitando arreglos manuales al incorporar otro nodo.
