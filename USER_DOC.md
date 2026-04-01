# USER_DOC — User & Administrator Documentation

This document explains how to use, access, and manage the Inception stack as an end user or administrator.

---

## 1. What Services Are Provided?

The stack exposes the following services once running:

| Service         | Description                                              | Access                          |
|-----------------|----------------------------------------------------------|---------------------------------|
| **WordPress**   | The main website / CMS                                   | `https://aayache.42.fr`         |
| **Adminer**     | Web UI for browsing and managing the MariaDB database    | `http://localhost:8083`         |
| **Static Site** | A standalone informational HTML website                  | `http://localhost:8081`         |
| **FileBrowser** | Web-based file manager for the WordPress volume          | `http://localhost:8082`         |
| **FTP**         | FTP access to the WordPress files                        | `ftp://localhost` (port 21)     |

> **Note:** The WordPress site uses a self-signed TLS certificate. Your browser will show a security warning — this is expected. Accept the exception to proceed.

---

## 2. Starting and Stopping the Project

All operations are handled via the `Makefile` at the root of the repository.

```bash
# Build images and start all containers in the background
make

# Stop all containers (data is preserved)
make down

# Start previously stopped containers (no rebuild)
make start

# Stop containers without removing them
make stop

# Restart all containers
make restart

# Follow live logs from all containers
make logs

# Show running container status
make ps
```

---

## 3. Accessing the Website and Administration Panel

### WordPress Front End
Open your browser and navigate to:
```
https://aayache.42.fr
```
Accept the self-signed certificate warning if prompted.

### WordPress Admin Panel
```
https://aayache.42.fr/wp-admin
```

Log in with the administrator credentials listed in Section 4 below.

### Adminer (Database UI)
```
http://localhost:8083
```
On the login screen, enter:
- **System**: MySQL
- **Server**: `mariadb`
- **Username**: `wpuser`
- **Password**: see `secrets/db_password.txt`
- **Database**: `wordpress`

### FileBrowser
```
http://localhost:8082
```
Log in with the FileBrowser credentials listed in Section 4.

---

## 4. Credentials

All credentials are stored in the `secrets/` directory at the root of the repository. **Do not commit this directory to a public repository.**

### `secrets/credentials.txt`

| Variable               | Value                   | Used for                         |
|------------------------|-------------------------|----------------------------------|
| `WP_ADMIN_USER`        | `aayache42`             | WordPress administrator login    |
| `WP_ADMIN_PASSWORD`    | `StrongAdminPass_123!`  | WordPress administrator password |
| `WP_ADMIN_EMAIL`       | `admin@aayache.42.fr`   | WordPress administrator email    |
| `WP_USER`              | `sbixla`                | WordPress author account login   |
| `WP_USER_PASSWORD`     | `StrongUserPass_123!`   | WordPress author password        |
| `FTP_USER`             | `ftpuser`               | FTP login                        |
| `FTP_PASSWORD`         | `supersecret`           | FTP password                     |
| `FILEBROWSER_USER`     | `admin`                 | FileBrowser login                |
| `FILEBROWSER_PASS`     | `adminadmin1234@@`      | FileBrowser password             |

### `secrets/db_password.txt`

| Variable          | Value               | Used for                    |
|-------------------|---------------------|-----------------------------|
| `MYSQL_PASSWORD`  | `StrongDbPass_123!` | MariaDB `wpuser` password   |

### `secrets/db_root_password.txt`

| Variable               | Value                  | Used for              |
|------------------------|------------------------|-----------------------|
| `MYSQL_ROOT_PASSWORD`  | `StrongRootPass_123!`  | MariaDB root password |

---

## 5. Checking That Services Are Running

### Quick status check
```bash
make ps
```
All containers should show status `Up`.

### Check logs for a specific service
```bash
# All services
make logs

# A single service (run directly with docker compose)
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f nginx
```

### Verify WordPress is reachable
```bash
curl -k https://aayache.42.fr
```
You should receive an HTML response from WordPress.

### Verify Redis is caching
Log into the WordPress admin panel → **Settings → Redis**. The status should read **Connected**.

Alternatively, from the host:
```bash
docker exec -it redis redis-cli ping
# Expected: PONG
```

### Verify MariaDB
```bash
docker exec -it mariadb mariadb-admin -u wpuser -pStrongDbPass_123! ping
# Expected: mysqld is alive
```
