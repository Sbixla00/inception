*This project has been created as part of the 42 curriculum by [aayache].*

---

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to broaden knowledge of system administration by using **Docker** to virtualize a small but complete infrastructure composed of several services, each running in its own dedicated container.

The stack is orchestrated via **Docker Compose** and includes:

- **NGINX** — the sole entry point to the infrastructure, serving HTTPS (TLS 1.2/1.3 only) on port 443 and acting as a reverse proxy to WordPress via FastCGI.
- **WordPress + PHP-FPM** — the CMS, configured with WP-CLI on startup. It connects to MariaDB for persistence and Redis for object caching.
- **MariaDB** — the relational database backend for WordPress.
- **Redis** — an in-memory object cache used by the WordPress Redis Cache plugin to speed up page loads.
- **FTP Server (vsftpd)** — allows file management of the WordPress volume over FTP.
- **Adminer** — a lightweight web-based database management UI.
- **Static Website** — a minimal standalone HTML/CSS/JS website served by NGINX on port 8081.
- **FileBrowser** — a web-based file manager exposing the WordPress volume on port 8082.

All images are built from **Alpine Linux 3.22** — no pre-built application images (e.g. `wordpress:latest`) are used.

### Design Choices

#### Virtual Machines vs Docker
Virtual Machines (VMs) emulate an entire hardware stack and run a full OS per instance, making them heavyweight and slow to start. Docker containers share the host kernel and isolate only the process and filesystem layer, making them significantly lighter, faster to spin up, and easier to reproduce. For a multi-service web stack like Inception, Docker is the natural fit.

#### Secrets vs Environment Variables
Plain environment variables are visible to any process in the container and can leak through `docker inspect` or logs. Docker **secrets** are mounted as read-only files under `/run/secrets/` and are only available to the containers explicitly granted access. Sensitive values (database passwords, admin credentials) are stored in `secrets/` files and sourced inside entrypoints — never hard-coded in images or Compose environment blocks.

#### Docker Network vs Host Network
Using a custom **bridge network** (`inception`) isolates all containers from the host network and from each other unless explicitly connected. Only the services that need external access (NGINX on 443, FTP on 21/21100, Adminer, static site, FileBrowser) publish ports to the host. `host` network mode removes this isolation and is avoided here for security and portability.

#### Docker Volumes vs Bind Mounts
**Bind mounts** map a specific host path into the container — useful when the host directory must survive container rebuilds and be directly accessible on the filesystem (e.g., `/home/aayache/data/wordpress`). **Named volumes** are managed entirely by Docker and are more portable. This project uses bind-mount-backed named volumes for `mariadb_data` and `wordpress_data` (so data persists at a predictable host path) and a pure named volume for `filebrowser_data`.

---

## Instructions

### Prerequisites

- Docker Engine ≥ 24 and Docker Compose V2
- A Linux host (tested on Debian/Ubuntu inside a VM)
- The domain `aayache.42.fr` must resolve to `127.0.0.1` on the host:
  ```
  echo "127.0.0.1 aayache.42.fr" | sudo tee -a /etc/hosts
  ```
---

## Resources

### Docker & Infrastructure
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Alpine Linux packages](https://pkgs.alpinelinux.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [Redis documentation](https://redis.io/docs/)
- [WP-CLI documentation](https://wp-cli.org/)
- [vsftpd manual](https://security.appspot.com/vsftpd.html)
- [FileBrowser documentation](https://filebrowser.org/)
- [Adminer](https://www.adminer.org/)

### Concepts
- [Containers vs VMs — Red Hat](https://www.redhat.com/en/topics/containers/containers-vs-vms)
- [Docker secrets — official guide](https://docs.docker.com/engine/swarm/secrets/)
- [Docker networking overview](https://docs.docker.com/network/)
- [Docker storage — volumes vs bind mounts](https://docs.docker.com/storage/)

### AI Usage
AI (Claude, Anthropic) was used during this project for the following tasks:
- **Debugging entrypoint scripts**: helping diagnose shell script issues (`set -eu`, secret sourcing, wait loops).
- **Docker Compose configuration**: reviewing service dependency ordering and volume definitions.
- **WordPress + Redis integration**: identifying the correct WP-CLI commands to configure and enable the Redis object cache plugin.

AI was **not** used to write the core Dockerfiles, entrypoint logic, or NGINX/MariaDB configuration from scratch — these were written and iterated on manually.
