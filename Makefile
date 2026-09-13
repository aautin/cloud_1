VENV=.venv
ANSIBLE_DIR=ansible
ANSIBLE_INVENTORY=$(ANSIBLE_DIR)/inventory.ini
ANSIBLE_PLAYBOOK=$(ANSIBLE_DIR)/site.yml
ANSIBLE=$(VENV)/bin/ansible
ANSIBLE_PLAYBOOK_BIN=$(VENV)/bin/ansible-playbook
ANSIBLE_CFG=$(ANSIBLE_DIR)/ansible.cfg

NGINX_DIR      = services/nginx
NGINX_CERT_KEY = $(NGINX_DIR)/certs/server.key
NGINX_CERT_CRT = $(NGINX_DIR)/certs/server.crt
NGINX_CERTS    = $(NGINX_CERT_KEY) $(NGINX_CERT_CRT)

.PHONY: local-down local-rm-volumes local-deploy ansible-deploy

$(NGINX_CERTS):
	mkdir -p services/nginx/certs 
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout $(NGINX_CERT_KEY) \
		-out $(NGINX_CERT_CRT) \
		-subj "/CN=localhost"

$(ANSIBLE_PLAYBOOK):
	uv sync

# ---------- LOCAL ----------
local-down:
	docker compose down

local-rm-volumes: local-down
	docker volume rm cloud_1_db_data
	docker volume rm cloud_1_wordpress_data

local-deploy: $(NGINX_CERTS)
	docker compose up -d --build 

local-logs:
	docker compose logs -f

local-recreate:
	docker compose up -d --build --force-recreate
# ------------------------------

# ---------- ANSIBLE ----------
ansible-deploy: $(NGINX_CERTS) $(ANSIBLE_PLAYBOOK)
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) $(ANSIBLE_PLAYBOOK_BIN) -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK)
# ------------------------------
