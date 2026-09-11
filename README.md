# cloud_1
Automated cloud infrastructure deployment and configuration using Ansible, Docker, SSH, and containerized services.

## EC2 configuration with Ansible

This setup targets an Ubuntu/Debian EC2 instance and configures Docker before deploying the `srcs/` Compose project.

From the repository root:

Install Ansible in the project virtual environment:

```sh
make ansible-install
```

This creates `.venv/` and installs the package listed in `ansible/requirements.txt`.

```sh
cp ansible/inventory.ini.example ansible/inventory.ini
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
```

Edit both files:

- set the EC2 public IP and SSH key in `ansible/inventory.ini`;
- replace every `CHANGE_ME` value in `ansible/group_vars/all.yml`.

For a real deployment, encrypt `all.yml` with Ansible Vault:

```sh
ansible-vault encrypt ansible/group_vars/all.yml
```

Check access, then deploy:

```sh
make ansible-ping
make ansible-deploy
```

The playbook installs Docker, creates persistent directories under `/srv/cloud_1`, copies `srcs/`, renders its `.env`, and starts the Compose stack.
