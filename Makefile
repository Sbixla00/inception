NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_DIR = /home/aayache/data
WP_DIR = $(DATA_DIR)/wordpress
DB_DIR = $(DATA_DIR)/mariadb

all: up

# Create required host directories for volumes
dirs:
	mkdir -p $(WP_DIR) $(DB_DIR)

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	docker system prune -af

fclean: clean
	docker volume prune -f

re: fclean up

.PHONY: all dirs up down stop start restart logs ps clean fclean re
