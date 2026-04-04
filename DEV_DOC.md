# DEV_DOC — Developer Documentation

This document explains how to set up, build, and manage the Inception project
from a developer's perspective.

---

## Prerequisites

Make sure the following tools are installed on the host machine before proceeding:

    Tool                Minimum version   Check with
    ----                ---------------   ----------
    Docker Engine       24.x              docker --version
    Docker Compose V2   2.x               docker compose version
    GNU Make            any               make --version

The project is designed to run on a Linux host. It has been tested on Debian/Ubuntu
inside a VirtualBox virtual machine.

---

## Setting up the environment from scratch

### 1. Clone the repository

    git clone <repo-url> inception
    cd inception

### 2. Add the domain to /etc/hosts

    echo "127.0.0.1 aayache.42.fr" | sudo tee -a /etc/hosts

### 3. Fill in the configuration files

srcs/.env contains non-sensitive runtime variables:

    DOMAIN_NAME=aayache.42.fr
    PASV_ADDRESS=10.0.2.15

Update PASV_ADDRESS to match the IP address of your host or VM interface
(the address FTP clients will use to connect in passive mode).

### 4. Fill in the secrets files

The following files must exist and contain valid values before the first run.
They are mounted into containers at runtime as Docker secrets and are never
baked into images.

    secrets/credentials.txt       WordPress admin/user accounts, FTP and FileBrowser
    secrets/db_password.txt       MYSQL_PASSWORD=<value>
    secrets/db_root_password.txt  MYSQL_ROOT_PASSWORD=<value>

The format used in each file is documented inside the file itself.
Never commit the secrets/ directory to a public repository.

### 5. Adjust the host data path (if needed)

The Makefile creates these host directories automatically on first run:

    /home/aayache/data/mariadb/
    /home/aayache/data/wordpress/

If your username differs from aayache, update the DATA_DIR variable in the
Makefile and the device: values under volumes in srcs/docker-compose.yml.

---

## Building and launching the project

The Makefile wraps all Docker Compose operations:

    make              create host directories, build all images, start containers
    make down         stop and remove containers  (data is preserved)
    make start        start previously stopped containers
    make stop         stop containers without removing them
    make restart      restart all containers
    make logs         follow live logs from all services
    make ps           list all containers and their status
    make clean        remove containers and images
    make fclean       remove containers, images, and Docker volumes  (destructive)
    make re           equivalent to: make fclean then make

To rebuild a single service after editing its Dockerfile or entrypoint:

    docker compose -f srcs/docker-compose.yml up -d --build <service>

---

## Managing containers and volumes

Open a shell inside a running container:

    docker exec -it <container-name> sh

Examples:
    docker exec -it wordpress sh
    docker exec -it mariadb sh
    docker exec -it nginx sh

Follow logs for one service:

    docker compose -f srcs/docker-compose.yml logs -f <service>

Inspect a volume:

    docker volume inspect inception_wordpress_data

List all volumes:

    docker volume ls

---

## Where project data is stored and how it persists

    Data             Host path                         Volume name
    ----             ---------                         -----------
    MariaDB          /home/aayache/data/mariadb/       mariadb_data
    WordPress files  /home/aayache/data/wordpress/     wordpress_data
    FileBrowser DB   managed by Docker (no host path)  filebrowser_data

Both mariadb_data and wordpress_data are declared as bind-mount-backed named
volumes (driver: local, type: none, o: bind). This means the data lives at the
specified host path and is not affected by docker compose down or docker system prune.

make fclean runs docker volume prune -f, which removes Docker-managed named
volumes (including filebrowser_data) but does NOT delete the bind-mount directories
on the host.

To fully wipe all data and start fresh:

    make fclean
    sudo rm -rf /home/aayache/data/
    make
