# USER_DOC — User and Administrator Documentation

This document explains how to use and manage the Inception stack as an end user
or administrator.

---

## Services provided by the stack

Once the project is running, the following services are available:

    Service          Address
    --------         -------
    WordPress        https://aayache.42.fr
    WordPress Admin  https://aayache.42.fr/wp-admin
    Adminer          http://localhost:8083
    Static Website   http://localhost:8081
    FileBrowser      http://localhost:8082
    FTP              ftp://localhost  (port 21)

Note: WordPress is served over HTTPS with a self-signed certificate. Your browser
will show a security warning on first visit — this is expected. Accept the exception
to continue.

---

## Starting and stopping the project

All operations are handled through the Makefile at the root of the repository.

    make              build images and start all containers
    make down         stop and remove containers  (data is preserved)
    make start        start previously stopped containers
    make stop         stop containers without removing them
    make restart      restart all containers
    make logs         follow live logs from all containers
    make ps           show the status of all containers

---

## Accessing the website and administration panel

Open a browser and go to:

    https://aayache.42.fr           main WordPress website
    https://aayache.42.fr/wp-admin  WordPress administration panel

On the admin login page, enter the credentials for the administrator account.
These are defined in the secrets/credentials.txt file (see section below).

---

## Locating and managing credentials

All credentials are stored in the secrets/ directory at the root of the repository.

    secrets/credentials.txt       WordPress admin and user accounts, FTP credentials,
                                  FileBrowser credentials
    secrets/db_password.txt       MariaDB application user password
    secrets/db_root_password.txt  MariaDB root password

To update a password, edit the relevant file and rebuild the affected service:

    docker compose -f srcs/docker-compose.yml up -d --build <service>

Never commit the secrets/ directory to a public repository.

---

## Checking that services are running correctly

Show the status of all containers:

    make ps

All containers should show a status of "Up". If any container is restarting or
has exited, check its logs:

    docker compose -f srcs/docker-compose.yml logs -f <service-name>

Check that MariaDB is accepting connections:

    docker exec -it mariadb mariadb-admin -u wpuser -p"<password>" ping

Check that Redis is responding:

    docker exec -it redis redis-cli ping

The expected output is: PONG

To confirm that WordPress is using the Redis object cache, log in to the admin
panel and go to Settings > Redis. The status should show "Connected".
