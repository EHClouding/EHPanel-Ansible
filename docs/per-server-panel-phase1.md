# EHPanel Web per-node phase 1

## Goal

Each Web VPS runs its own EHPanel Web instance. Billing keeps calling the existing `/api/v1/billing/...` contract over HTTP. Core is not used for provisioning.

## Runtime

- Nginx is the public edge.
- OpenLiteSpeed is the hosting backend.
- EHPanel Web runs as a local Django/Channels panel on `127.0.0.1:8004`.
- Provisioning uses `HOSTING_PROVISIONING_MODE=local`.
- The Go agent is disabled by default in this phase and remains reserved for later monitoring, updates and telemetry.

## Required inventory variables

Set these per test VM or VPS:

- `ehpanel_web_panel_source_path`: controller path to the EHPanel Web copy.
- `ehpanel_web_panel_domain`: panel hostname for this node.
- `ehpanel_web_panel_public_url`: public panel URL.
- `ehpanel_web_panel_secret_key`: Django secret.
- `ehpanel_web_panel_billing_token`: token shared with Billing.
- `ehpanel_web_panel_app_version`: version reported to Core and Billing.
- `ehpanel_web_panel_core_api_user`: API user accepted from Core.
- `ehpanel_web_panel_core_api_key`: API key accepted from Core; store it in vault.
- `ehpanel_web_panel_core_allow_deploy`: keep `false` unless Core should execute updates.
- `ehpanel_web_panel_core_deploy_script`: controlled deploy script when remote deploy is enabled.
- `ehpanel_web_panel_database_url`: PostgreSQL URL for the local panel DB.
- `ehpanel_web_panel_local_public_ip`: public IP used in DNS records.
- `ehpanel_web_panel_provision_ssl`: keep `false` on a private VM; enable it on the temporary public VPS.

## Validation order

1. Run `playbooks/web-node.yml` against a disposable VM.
2. Confirm `/health/` and `/api/v1/billing/health/`.
3. Confirm `/api/v1/core/verify/` with `X-API-User` and `X-API-Key`.
4. Create a small plan in the panel.
5. Send a Billing provision request with a test domain.
6. Verify Linux user, `/home/<user>/public_html`, Nginx vhost and OpenLiteSpeed vhost.
7. Only after local VM validation, test public DNS and free SSL on a temporary VPS.
