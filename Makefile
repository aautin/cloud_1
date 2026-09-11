VENV=.venv
ANSIBLE_DIR=ansible
ANSIBLE_INVENTORY=$(ANSIBLE_DIR)/inventory.ini
ANSIBLE_PLAYBOOK=$(ANSIBLE_DIR)/site.yml
ANSIBLE=$(VENV)/bin/ansible
ANSIBLE_PLAYBOOK_BIN=$(VENV)/bin/ansible-playbook
ANSIBLE_CFG=$(ANSIBLE_DIR)/ansible.cfg

.PHONY: ansible-ping ansible-deploy ansible-install

ansible-ping:
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) $(ANSIBLE) -i $(ANSIBLE_INVENTORY) cloud -m ping
ansible-deploy:
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) $(ANSIBLE_PLAYBOOK_BIN) -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK)
ansible-install:
	uv sync
