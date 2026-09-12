VENV=.venv
ANSIBLE_DIR=ansible
ANSIBLE_INVENTORY=$(ANSIBLE_DIR)/inventory.ini
ANSIBLE_PLAYBOOK=$(ANSIBLE_DIR)/site.yml
ANSIBLE=$(VENV)/bin/ansible
ANSIBLE_PLAYBOOK_BIN=$(VENV)/bin/ansible-playbook
ANSIBLE_CFG=$(ANSIBLE_DIR)/ansible.cfg

.PHONY: ansible-deploy ansible-install

ansible-deploy:
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) $(ANSIBLE_PLAYBOOK_BIN) -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK)
ansible-install:
	uv sync
