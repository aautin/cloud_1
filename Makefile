VENV=.venv

ANSIBLE_DIR          = ansible
ANSIBLE_INVENTORY    = ansible/inventory.ini
ANSIBLE_PLAYBOOK     = ansible/site.yml
ANSIBLE_CFG          = ansible/ansible.cfg
ANSIBLE_VAULT        = ansible/group_vars/vault.yml
ANSIBLE_REQUIREMENTS = ansible/requirements.yml
ANSIBLE_TO_CREATE    = ansible/group_vars/all.yml ansible/inventory.ini

ANSIBLE_BIN        = $(VENV)/bin/ansible-playbook
ANSIBLE_VAULT_BIN  = $(VENV)/bin/ansible-vault
ANSIBLE_GALAXY_BIN = $(VENV)/bin/ansible-galaxy

NGINX_DIR      = services/nginx
NGINX_CERT_KEY = $(NGINX_DIR)/certs/server.key
NGINX_CERT_CRT = $(NGINX_DIR)/certs/server.crt
NGINX_CERTS    = $(NGINX_CERT_KEY) $(NGINX_CERT_CRT)

.PHONY: local-down local-recreate local-rm-volumes local-hosts local-deploy \
		ansible-encrypt ansible-collections ansible-deploy 


# ---------- LOCAL PREDEPLOYMENT ----------
$(NGINX_CERTS):
	mkdir -p services/nginx/certs 
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout $(NGINX_CERT_KEY) \
		-out $(NGINX_CERT_CRT) \
		-subj "/CN=localhost"
# ------------------------------


# ---------- ANSIBLE PREDEPLOYMENT ----------
$(ANSIBLE_BIN):
	uv sync

$(ANSIBLE_TO_CREATE):
	@echo "Please edit $@ to set your configuration."
	@echo "Then run 'make ansible-deploy' to deploy the application."
	@exit 1

$(ANSIBLE_VAULT): $(ANSIBLE_BIN)
	@echo "Please edit the ansible group_vars/vault.yml file to set your vault variables."
	$(ANSIBLE_VAULT_BIN) create $@
# ------------------------------


# ---------- LOCAL DEPLOYMENT ----------
local-hosts:
	@set -eu; \
	app_domain=$$(sed -n 's/^APP_DOMAIN=//p' .env | head -n 1 | sed 's/^['"'"']//; s/['"'"']$$//'); \
	if [ -z "$$app_domain" ]; then \
		echo "APP_DOMAIN must be set in .env" >&2; \
		exit 1; \
	fi; \
	if awk -v domain="$$app_domain" '$$1 !~ /^#/ { for (field = 2; field <= NF; field++) if ($$field == domain) found = 1 } END { exit !found }' /etc/hosts; then \
		echo "$$app_domain already exists in /etc/hosts"; \
	else \
		echo "Adding $$app_domain to /etc/hosts"; \
		printf '127.0.0.1 %s\n' "$$app_domain" | sudo tee -a /etc/hosts >/dev/null; \
	fi

local-down:
	docker compose down --remove-orphans

local-rm-volumes: local-down
	docker volume rm cloud_1_db_data
	docker volume rm cloud_1_wordpress_data

local-deploy: local-hosts $(NGINX_CERTS)
	docker compose up -d --build

local-logs:
	docker compose logs -f

local-recreate:
	docker compose up -d --build --force-recreate
# ------------------------------


# ---------- ANSIBLE DEPLOYMENT ----------
ansible-encrypt: $(ANSIBLE_BIN) $(ANSIBLE_VAULT)
	$(ANSIBLE_VAULT_BIN) encrypt $(ANSIBLE_VAULT)

ansible-collections: $(ANSIBLE_BIN)
	$(ANSIBLE_GALAXY_BIN) collection install -r $(ANSIBLE_REQUIREMENTS)

ansible-deploy: ansible-collections $(ANSIBLE_BIN) $(ANSIBLE_TO_CREATE) $(ANSIBLE_VAULT)
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) $(ANSIBLE_BIN) --ask-vault-pass -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK)
# ------------------------------
