# DEV_DOC — Developer Documentation

This document explains how to set up, build, run, and maintain the Inception project from a developer's perspective.

---

## 1. Prerequisites

Make sure the following are installed on your machine before proceeding:

| Tool               | Minimum version | Check command            |
|--------------------|-----------------|--------------------------|
| Docker Engine      | 24.x            | `docker --version`       |
| Docker Compose V2  | 2.x             | `docker compose version` |
| GNU Make           | any             | `make --version`         |
| curl / openssl     | any             | available on most Linux  |

The project is designed to run on a **Linux host** (Debian/Ubuntu recommended). It has been tested inside a VirtualBox VM.

---

## 2. Repository Layout

```
.
├── Makefile                          # Top-level build orchestration
├── secrets/
│   ├── credentials.txt               # WordPress, FTP, FileBrowser creds
│   ├── db_password.txt               # MariaDB wpuser password
│   └── db_root_password.txt          # MariaDB root password
└── srcs/
    ├── .env                          # Non-secret runtime variables
    ├── docker-compose.yml            # Full service definition
    └── requirements/
        ├── mariadb/                  # MariaDB image (Alpine)
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/entrypoint.sh
        ├── nginx/                    # NGINX image (Alpine, TLS)
        │   ├── Dockerfile
        │   ├── conf/default.conf
        │   └── tools/entrypoint.sh
        ├── wordpress/                # WordPress + PHP-FPM image (Alpine)
        │   ├── Dockerfile
        │   └── tools/entrypoint.sh
        └── bonus/
            ├── redis/                # Redis image (Alpine)
            ├── ftp/                  # vsftpd image (Alpine)
            ├── adminer/              # Adminer image (Alpine + PHP)
            ├── static-website/       # Static NGINX site (Alpine)
            └── filebrowser/          # FileBrowser image (Alpine)
```

---

## 3. Configuration Files

### `srcs/.env`
Contains non-sensitive variables injected into containers via `env_file`:

```dotenv
DOMAIN_NAME=aayache.42.fr
PASV_ADDRESS=10.0.2.15       # Host IP seen by FTP clients (PASV mode)
```

Update `PASV_ADDRESS` to match the IP address of your host/VM interface if it differs.

### `secrets/`
Contains three files sourced inside every entrypoint via:
```sh
set -a
. /run/secrets/credentials
. /run/secrets/db_password
. /run/secrets/db_root_password
set +a
```

These files are **never baked into images** — they are mounted at runtime by Docker secrets. See `srcs/docker-compose.yml` for the `secrets:` declarations.

### Host name resolution
Add the domain to `/etc/hosts` on the host machine:
```bash
echo "127.0.0.1 aayache.42.fr" | sudo tee -a /etc/hosts
```

### Data directories
The Makefile creates these before starting containers:
```
/home/aayache/data/wordpress/   ← WordPress files (bind mount)
/home/aayache/data/mariadb/     ← MariaDB data (bind mount)
```
If your username differs from `aayache`, update `DATA_DIR` in the `Makefile` and the `device:` paths in `docker-compose.yml` volumes section.

---

## 4. Building and Launching

```bash
# Full build + start (the default target)
make

# Which is equivalent to:
make dirs   # mkdir -p the data directories
make up     # docker compose up -d --build
```

Docker Compose builds each image from its own `Dockerfile` and wires everything together. On first run, WordPress's entrypoint will:
1. Wait for MariaDB to accept connections.
2. Wait for Redis to be reachable.
3. Download WordPress core via WP-CLI.
4. Generate `wp-config.php` with database + Redis constants.
5. Run `wp core install` to initialize the database.
6. Create the non-admin author account.
7. Install and activate the Redis Cache plugin.
8. Hand off to `php-fpm83`.

This initialization happens **only once** because subsequent runs detect `wp-config.php` and an installed database.

---

## 5. Useful Container Management Commands

```bash
# Rebuild and restart a single service (e.g. after editing its Dockerfile)
docker compose -f srcs/docker-compose.yml up -d --build wordpress

# Execute a shell inside a running container
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it nginx sh

# Follow logs for one service
docker compose -f srcs/docker-compose.yml logs -f nginx

# Inspect all running containers
make ps

# Stop everything (keeps volumes and images)
make down

# Remove all containers and images (keeps volumes/data)
make clean

# Remove everything including volumes (DESTRUCTIVE — data loss)
make fclean

# Full rebuild from scratch
make re
```

---

## 6. Data Persistence

### Where data lives

| Data                | Host path                          | Volume name      |
|---------------------|------------------------------------|------------------|
| MariaDB database    | `/home/aayache/data/mariadb/`      | `mariadb_data`   |
| WordPress files     | `/home/aayache/data/wordpress/`    | `wordpress_data` |
| FileBrowser DB      | Docker-managed named volume        | `filebrowser_data` |

Both `mariadb_data` and `wordpress_data` use the `local` driver with `type: none` and `o: bind` — meaning Docker treats them as named volumes but they are actually bind-mounted to specific host paths. This guarantees data survives `docker compose down` and even `docker system prune`.

`make fclean` calls `docker volume prune -f`, which removes **only** Docker-managed named volumes (including `filebrowser_data`). The bind-mount directories on the host (`/home/aayache/data/`) are **not** automatically deleted — remove them manually if needed:

```bash
sudo rm -rf /home/aayache/data/
```

### Resetting WordPress or MariaDB only
```bash
# Stop containers
make down

# Clear WordPress files
sudo rm -rf /home/aayache/data/wordpress/*

# Clear database
sudo rm -rf /home/aayache/data/mariadb/*

# Rebuild
make up
```

---

## 7. TLS Certificate

The NGINX entrypoint generates a **self-signed certificate** at first start:
```
/etc/nginx/ssl/nginx.crt
/etc/nginx/ssl/nginx.key
```
The certificate is generated inside the container (not persisted to a volume), so it is regenerated on every container start. The subject CN is set to `aayache.42.fr` with a matching SAN extension.

To inspect it:
```bash
docker exec -it nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -text
```

---

## 8. Adding or Modifying a Service

1. Create a new directory under `srcs/requirements/bonus/<service>/`.
2. Write a `Dockerfile` based on `alpine:3.22` (no pre-built app images).
3. Add an `entrypoint.sh` that sources secrets and starts the process.
4. Add the service block to `srcs/docker-compose.yml` (network, volumes, ports, secrets as needed).
5. Run `make re` to rebuild from scratch, or `docker compose -f srcs/docker-compose.yml up -d --build <service>` for an incremental rebuild.
