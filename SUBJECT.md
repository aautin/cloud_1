# Cloud-1: Automated Deployment of Inception

## Objective

Deploy a WordPress website and its Docker infrastructure on a cloud server. The deployment must be automated and reproducible from a fresh Ubuntu 22.04-like server.

The project is based on Inception, but the deployment must use one container per process rather than simply reusing the original Inception images and setup.

## Platform

The server must be hosted outside the 42 infrastructure. Possible providers include AWS, Azure, GCP, Scaleway, or another suitable cloud provider.

The student is responsible for:

- Choosing an appropriately sized instance.
- Monitoring cloud usage and costs.
- Stopping or deleting unused resources.
- Keeping provider credentials, keys, and identifiers out of the repository.

## Mandatory requirements

The project must satisfy all of the following:

- Deploy a functional WordPress site.
- Automate the complete deployment with Ansible or another automation tool.
- Make the site restart automatically after a server reboot.
- Preserve all site data after reboots and container recreation, including:
  - WordPress files and uploads.
  - User accounts.
  - Articles and other database content.
- Deploy the same application to several servers in parallel.
- Work on a fresh Ubuntu 22.04-like server with only SSH and Python assumed to be available.
- Run application components in separate containers, with one process per container.
- Allow the containers to communicate through private networks.
- Use a `docker-compose.yml` file.
- Include the different components required by WordPress, such as:
  - WordPress.
  - A MySQL-compatible database such as MariaDB or MySQL.
  - phpMyAdmin or an equivalent database administration service.
  - A reverse proxy or web server.
- Ensure the database works with both WordPress and phpMyAdmin.
- Prevent direct public access to the database.
- Support TLS/HTTPS when the deployment environment allows it.
- Route requests to the correct site depending on the requested URL.
- Expose only these public ports:
  - `22` for SSH.
  - `80` for HTTP.
  - `443` for HTTPS.
- Organize the Ansible implementation into maintainable roles.
- Make the deployment portable so it works on a clean server, not only on the development machine.
- Use official Docker images where appropriate.
- Make the deployment idempotent: running it repeatedly must leave the system in the same working state.
- Never hard-code secrets such as database passwords in tracked source files.

## Expected architecture

A typical architecture is:

```text
Internet
   |
   | ports 80 and 443
   v
Reverse proxy (Nginx, Apache, Caddy, or another tool)
   |
   +--> WordPress container
   |
   +--> phpMyAdmin container

WordPress and phpMyAdmin
   |
   v
Database container

Database and application data are stored in persistent volumes.
```

Only the reverse proxy should publish HTTP and HTTPS ports. WordPress, phpMyAdmin, and the database should communicate over an internal Docker network. The database must not publish port `3306` publicly.

## Automation expectations

The automation should install and configure everything needed on the target machine, including where applicable:

- Required system packages.
- Docker Engine and the Compose plugin.
- The host firewall.
- Application directories.
- Docker Compose files and service configuration.
- Persistent storage directories or volumes.
- TLS certificates and reverse-proxy configuration.
- Secrets supplied securely through Ansible Vault, protected variables, or another secret-management mechanism.
- The application startup and restart behavior.

Ansible roles should have focused responsibilities, for example:

- `common`: base packages, users, directories, and firewall.
- `docker`: Docker installation and service configuration.
- `app`: Compose files, environment configuration, volumes, and deployment.
- `tls`: certificates and HTTPS configuration, if separated from the application role.

## Security requirements

- Permit only SSH, HTTP, and HTTPS from outside the server.
- Do not expose MySQL/MariaDB, WordPress, or phpMyAdmin directly to the internet.
- Use strong credentials.
- Do not commit `.env` files containing real secrets.
- Do not commit cloud provider credentials, private keys, or server identifiers that should remain private.
- Use TLS for public traffic whenever a domain and certificate can be configured.
- Consider redirecting HTTP traffic to HTTPS.

## Persistence and recovery checks

The deployment should be tested by:

1. Creating WordPress content and a user.
2. Restarting the containers.
3. Rebooting the server.
4. Recreating the containers without deleting volumes.
5. Confirming that the content, users, uploads, and database data remain available.
6. Running the deployment a second time and confirming that it remains functional without destructive changes.

## Cloud cost warning

Cloud resources may incur real charges. Use the smallest suitable instance and free-tier resources where available. Stop or remove instances and services when they are not being used.

## AI and project responsibility

AI may be used as a development aid, but the student remains responsible for understanding and defending every design and implementation decision. AI-generated code should be reviewed, tested, and discussed with peers. The use of AI should be transparent when required by the school or project process.

## Suggested implementation order

1. Build and test the database container with persistent storage.
2. Add WordPress and verify its database connection.
3. Add phpMyAdmin on the private Docker network.
4. Add the reverse proxy and HTTP routing.
5. Add HTTPS/TLS.
6. Add Ansible roles and deploy to a clean server.
7. Configure firewall rules and verify the exposed ports.
8. Test reboot recovery, persistence, idempotence, and multi-server deployment.
