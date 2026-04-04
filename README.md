*This project has been created as part of the 42 curriculum by aayache.*

---

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to
build a small but complete web infrastructure using Docker, where each service runs
in its own dedicated container built from scratch on Alpine Linux 3.22.

The infrastructure is orchestrated with Docker Compose and includes the following services:

- NGINX — the only entry point to the stack, serving HTTPS on port 443 (TLS 1.2/1.3),
  acting as a reverse proxy to WordPress via FastCGI.
- WordPress + PHP-FPM — the main CMS, set up automatically at first start via WP-CLI.
- MariaDB — the relational database used by WordPress.
- Redis — an in-memory object cache connected to WordPress via the Redis Cache plugin.
- FTP (vsftpd) — allows FTP access to the WordPress files.
- Adminer — a lightweight web interface for managing the database.
- Static Website — a simple standalone HTML/CSS/JS page served by NGINX.
- FileBrowser — a web-based file manager exposing the WordPress volume.

### Use of Docker

Docker is used to isolate each service into its own container with its own filesystem,
process space, and network interface. All images are built from Alpine Linux 3.22 using
custom Dockerfiles — no pre-built application images (e.g. wordpress:latest) are used.
Docker Compose handles the wiring: networking, volumes, secrets, dependencies, and restart
policies are all declared in srcs/docker-compose.yml.

### Main Design Choices

**Virtual Machines vs Docker**
A VM emulates a full hardware stack and runs a complete operating system per instance,
making it resource-heavy and slow to start. Docker containers share the host kernel and
isolate only the process and filesystem layer. For a reproducible multi-service web stack
like this one, containers are significantly lighter and faster to spin up.

**Secrets vs Environment Variables**
Plain environment variables are exposed to any process running in the container and
can be read via `docker inspect`. Docker secrets are mounted as read-only files under
`/run/secrets/` inside the container and are only accessible to services that explicitly
declare them. All sensitive values in this project (passwords, credentials) are managed
through Docker secrets, never hard-coded in images or Compose env blocks.

**Docker Network vs Host Network**
Using a custom bridge network (named `inception`) isolates all containers from the host
network and from each other by default. Containers can only communicate if they are on
the same network, and only explicitly published ports are reachable from outside.
Host network mode removes all this isolation and is avoided here for both security and
portability reasons.

**Docker Volumes vs Bind Mounts**
A bind mount maps a specific directory on the host into the container — data is stored
at a known host path and survives container rebuilds. A named volume is managed entirely
by Docker and is more portable but less predictable in location.
This project uses bind-mount-backed named volumes for wordpress_data and mariadb_data
(data is stored at /home/aayache/data/ on the host) and a pure named volume for
filebrowser_data.

---

## Instructions

### Prerequisites

- Docker Engine >= 24 and Docker Compose V2 installed on a Linux host.
- The project domain must resolve locally. Add this line to /etc/hosts:

      127.0.0.1 aayache.42.fr

- Fill in the secrets files before the first run (see DEV_DOC.md for details).

### Running the project

    make            build all images and start the stack
    make down       stop and remove containers (data is preserved)
    make start      start previously stopped containers
    make stop       stop containers without removing them
    make restart    restart all containers
    make logs       follow live logs from all services
    make ps         show status of all containers
    make clean      remove containers and images
    make fclean     full reset — removes containers, images, and volumes
    make re         fclean followed by a full rebuild

For detailed usage instructions see USER_DOC.md.
For developer setup and configuration details see DEV_DOC.md.

---

## Resources

Docker and infrastructure:

- Docker official documentation — https://docs.docker.com/
- Docker Compose file reference — https://docs.docker.com/compose/compose-file/
- Docker secrets — https://docs.docker.com/engine/swarm/secrets/
- Docker networking overview — https://docs.docker.com/network/
- Docker storage: volumes and bind mounts — https://docs.docker.com/storage/
- Alpine Linux package index — https://pkgs.alpinelinux.org/

Services:

- NGINX documentation — https://nginx.org/en/docs/
- MariaDB knowledge base — https://mariadb.com/kb/en/
- Redis documentation — https://redis.io/docs/
- WP-CLI commands — https://developer.wordpress.org/cli/commands/
- vsftpd manual — https://security.appspot.com/vsftpd.html
- FileBrowser documentation — https://filebrowser.org/
- Adminer — https://www.adminer.org/

Concepts:

- Containers vs Virtual Machines — https://www.redhat.com/en/topics/containers/containers-vs-vms
- TLS/SSL overview — https://www.cloudflare.com/learning/ssl/what-is-ssl/
- PHP-FPM — https://www.php.net/manual/en/install.fpm.php

### How AI was used

AI assistance (Claude by Anthropic) was used in the following parts of this project:

- Debugging shell entrypoint scripts, specifically issues with `set -eu`, secret file
  sourcing, and service wait loops.
- Reviewing Docker Compose service dependency ordering and volume configuration.
- Understanding the correct WP-CLI sequence to install, configure, and activate the
  Redis Cache plugin on first startup.

AI was not used to write the core Dockerfiles, NGINX/MariaDB configuration files,
or entrypoint logic from scratch — those were written and debugged manually.
