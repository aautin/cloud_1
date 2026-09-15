# Cloud 1

## Project Scope

Automated deployment of a WordPress application on a cloud server.
> The project uses **Docker Compose** for the application stack and **Ansible** to prepare and deploy the stack on one or more Ubuntu hosts.

This project does not provision cloud instances, manage provider billing, or store cloud credentials. Those responsibilities remain provider-specific and must be handled outside the repository.

## Contents

- [Project Scope](#project-scope)
- [The app](#the-app)
	- [Features](#features)
	- [Networking](#networking)
- [Requirements](#requirements)
	- [Local deployment](#local-deployment)
	- [Remote deployment](#remote-deployment)
	- [Control node](#control-node)
	- [Managed node](#managed-node)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
	- [Self-signed TLS certificate](#self-signed-tls-certificate)
	- [Local Compose deployment](#local-compose-deployment)
	- [Ansible deployment](#ansible-deployment)
- [TLS and Security](#tls-and-security)

## The app

### Features

- WordPress with persistent application files and uploads.
- MySQL 8 with persistent database storage.
- phpMyAdmin connected to the same private database network.
- Nginx as the only public HTTP/HTTPS entry point.
- Automatic container restart and Docker service startup after a reboot.
- Ansible roles for base packages, Docker, firewall rules, TLS, and the application deployment.
- Ansible Vault for database and WordPress administrator passwords.
- Local Compose deployment for development and testing.

### Networking

- The containers communicate over the `cloud_1` Docker network.
- Database, WordPress and phpMyAdmin containers do not publish ports directly to the host.
- Nginx is the only public entry point for HTTP protocol, it routes requests to the application containers.
- SSH port 22, HTTP port 80 and HTTPS port 443 are the only open ports by the firewall ansible configuration.
- PhpMyAdmin is a service restricted by Nginx to be accessible only from the VPS itself and from the deployment machine.

## Requirements

### Local deployment
> Control and managed nodes are the same machine

**Runs the local Makefile and Docker Compose commands.**

- Docker Engine with the Compose plugin.
- `make`, `openssl`, `curl`, `sudo`, and a POSIX-compatible shell.
- a local `.env` file copied from `.env.example`.
- permission to add a new domain entry to `/etc/hosts`.
- Runs the local WordPress, MySQL, phpMyAdmin, and Nginx containers.
- ports 80 and 443 to be available locally.
- Self-sign its TLS certificate when deploying, if not present yet.

### Remote deployment
> Control and managed nodes are **not** the same machine

#### Control node

**Runs Ansible against one or more remote servers.**

- SSH, `make`, `curl`, `uv`, and `Python 3.14` or newer.
- the IP and the SSH user of the remote server.
- the private SSH key for the remote server.
- the Ansible inventory and encrypted Vault file.

#### Managed node

**The cloud server where the application is deployed.**

- an Ubuntu-LTS (22.04 or newer).
- SSH, and Python for running the Ansible interpreted modules.

## Project Structure

```text
.
├── ansible/                  # Ansible deployment configuration
│   ├── roles/                # Reusable task groups for deployment responsibilities
│   ├── group_vars/           # Inventory variables and encrypted secrets
│   ├── templates/app.env.j2  # Template for the generated .env file on the managed node
│   ├── inventory.ini         # List of the managed nodes with SSH connection details
│   ├── requirements.yml      # Ansible collection dependencies
│   └── site.yml              # Main playbook, listing the roles to run
|
├── services/                 # Container-specific files and configurations
├── docker-compose.yml        # Containers, networks, volumes, healthchecks, and ports
├── Makefile                  # Local Compose and remote Ansible commands
|
├── pyproject.toml            # Python project metadata and Ansible dependency
├── .python-version           # Python version for the control-node environment
|
└── SUBJECT.md                # Project requirements and expected architecture
```

## Configuration

### Self-signed TLS certificate

The certificate generated (local and remote) is self-signed. Browsers will show a warning, and `curl` requires `-k` to ignore the certificate validation.

### Local Compose deployment

Copy the example environment file and fill in every value:

```sh
cp .env.example .env
${EDITOR:-vi} .env
```

Set `APP_DOMAIN` to the hostname used in the browser. For a local deployment, the `local-hosts` target adds that hostname to `/etc/hosts` and points it to `127.0.0.1` when it is missing:

```env
APP_DOMAIN=mycloud1.example.com
```

For local-only testing, use `APP_DOMAIN=localhost` instead. The WordPress data volume retains the URL from the first installation, so changing `APP_DOMAIN` after installation may require a deliberate WordPress URL migration.

Useful local commands:

```sh
make local-logs
make local-recreate
make local-down
make local-rm-volumes       # WARNING: removes volumes, LOSING ALL DATA
```

### Ansible deployment

Create the ignored deployment files from their examples:

```sh
cp ansible/inventory.ini.example ansible/inventory.ini
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
```

Edit the inventory with the real host, SSH user, and private-key path. Edit `ansible/group_vars/all.yml` with the domain, WordPress metadata, and database name/user. Create the encrypted Vault file for the three password variables:

```sh
make ansible-deploy
```

The target installs the required Ansible collection, asks for the Vault password, discovers the deployment machine's public IPv4 address, and runs the playbook. The playbook loads `ansible/group_vars/vault.yml` explicitly. Never commit the inventory, `all.yml`, `vault.yml`, private keys, certificates, or `.env` files containing real secrets.

To deploy to several machines, put all of them in the `[cloud]` inventory group. Ansible will target the group and can run hosts in parallel according to its fork configuration:

```ini
[cloud]
server_one ansible_host=203.0.113.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cloud_one
server_two ansible_host=203.0.113.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cloud_one
```

## TLS and Security

The current automated certificate path creates a self-signed certificate when one is absent. This is suitable for development or controlled testing only. For a public deployment, configure a real DNS name and replace the self-signed certificate flow with a trusted certificate, such as Let's Encrypt, including renewal.

The database has no published port. phpMyAdmin is routed through Nginx and should be additionally restricted for a public deployment, for example with an IP allowlist, VPN, or another access-control layer. Use strong unique passwords in Ansible Vault.
