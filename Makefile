# EHPanel-Ansible Makefile
# Usage: make <target>

STAGING_INVENTORY  := inventories/staging/hosts.yml
PROD_INVENTORY     := inventories/production/hosts.yml
VAULT_FLAGS        := --ask-vault-pass
DIFF_FLAGS         := --diff

.PHONY: help deps lint staging-web staging-web-check prod-web prod-web-check \
        validate-staging validate-prod agent-register-staging \
        update-php-staging update-certs-staging

help:
	@echo ""
	@echo "EHPanel-Ansible — available targets:"
	@echo ""
	@echo "  deps                     Install Ansible Galaxy collections"
	@echo "  lint                     Run ansible-lint on all playbooks"
	@echo ""
	@echo "  staging-web-check        Dry-run web-node.yml on staging (--check --diff)"
	@echo "  staging-web              Apply web-node.yml on staging"
	@echo "  validate-staging         Run validate.yml on staging (read-only)"
	@echo "  agent-register-staging   Re-run enrollment for staging agent"
	@echo "  update-php-staging       Update PHP versions on staging"
	@echo "  update-certs-staging     Renew/issue TLS certificates on staging"
	@echo ""
	@echo "  prod-web-check           Dry-run web-node.yml on production"
	@echo "  prod-web                 Apply web-node.yml on production (asks confirmation)"
	@echo "  validate-prod            Run validate.yml on production"
	@echo ""

deps:
	ansible-galaxy collection install -r requirements.yml --force

lint:
	ansible-lint playbooks/web-node.yml playbooks/validate.yml

# ── Staging ───────────────────────────────────────────────────────────────────

staging-web-check:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/web-node.yml \
	  --check $(DIFF_FLAGS) $(VAULT_FLAGS)

staging-web:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/web-node.yml \
	  $(DIFF_FLAGS) $(VAULT_FLAGS)

validate-staging:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/validate.yml \
	  $(VAULT_FLAGS)

agent-register-staging:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/agent-register.yml \
	  $(VAULT_FLAGS)

update-php-staging:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/update-php.yml \
	  $(DIFF_FLAGS) $(VAULT_FLAGS)

update-certs-staging:
	ansible-playbook -i $(STAGING_INVENTORY) \
	  playbooks/update-certs.yml \
	  $(VAULT_FLAGS)

# ── Production ────────────────────────────────────────────────────────────────

prod-web-check:
	ansible-playbook -i $(PROD_INVENTORY) \
	  playbooks/web-node.yml \
	  --check $(DIFF_FLAGS) $(VAULT_FLAGS)

prod-web:
	@echo "WARNING: This will modify PRODUCTION nodes."
	@read -p "Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	ansible-playbook -i $(PROD_INVENTORY) \
	  playbooks/web-node.yml \
	  $(DIFF_FLAGS) $(VAULT_FLAGS)

validate-prod:
	ansible-playbook -i $(PROD_INVENTORY) \
	  playbooks/validate.yml \
	  $(VAULT_FLAGS)
