# ==================================================================================== #
## ===== HELPERS =====
# ==================================================================================== #
## help: Describe all the targets
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## all: call the help
.PHONY: all
all: help
# ==================================================================================== #





# ==================================================================================== #
## ===== MAIN COMMANDS =====
# ==================================================================================== #
## up: Run infra stack
.PHONY: up
up:
	@START=$$(date +%s); \
	echo 'Starting infra stack containers...'; \
	docker-compose up -d; \
	END=$$(date +%s); \
	ELAPSED=$$((END-START)); \
	echo "infra stack started in $$((ELAPSED/3600))h $$(((ELAPSED%3600)/60))m $$((ELAPSED%60))s"

## down: Remove all infra containers
.PHONY: down
down:
	@START=$$(date +%s); \
	echo 'cleaning up infra stack...'; \
	docker-compose down; \
	END=$$(date +%s); \
	ELAPSED=$$((END-START)); \
	echo "cleaning up completed in $$((ELAPSED/3600))h $$(((ELAPSED%3600)/60))m $$((ELAPSED%60))s"

## restart: Restart the infra stack
.PHONY: restart
restart: confirm down up
	@echo "infra stack restarted"
# ==================================================================================== #





# ==================================================================================== #
## ===== UTILITIES =====
# ==================================================================================== #
## create/network: Create the infra network (gorilla-roxo-cloud-network) to be used in docker
.PHONY: create/network
create/network:
	echo 'creating infra network...'
	@docker network create gorilla-roxo-cloud-network

## docker/kill/all: Stop and Remove --ALL-- containers
.PHONY: docker/kill/all
docker/kill/all: confirm
	@START=$$(date +%s); \
	echo 'Stopping and Removing ALL containers...'; \
	docker stop $$(docker ps -q) && docker rm $$(docker ps -a -q); \
	END=$$(date +%s); \
	ELAPSED=$$((END-START)); \
	echo "Finished Stopping and Removing ALL containers in $$((ELAPSED/3600))h $$(((ELAPSED%3600)/60))m $$((ELAPSED%60))s"

## setup/folders: Create all the necessary folder and permissions for the containers to work
.PHONY: setup/folders
setup/folders:
	@$(MAKE) --no-print-directory create/folder FOLDER_NAME=odoo UID=100 GID=101





# ==================================================================================== #
# ===== INTERNAL TARGETS =====
# ==================================================================================== #
# Create a folder in the .docker_volume folder with the given ID
.PHONY: create/folder
create/folder:
	@DIR_PATH=$(shell pwd)/.docker_volume/$(FOLDER_NAME); \
	echo "Setting up folder: $$DIR_PATH with UID: $(UID) and GID: $(GID)"; \
	sudo mkdir -p $$DIR_PATH; \
	sudo chown -R $(UID):$(GID) $$DIR_PATH; \
	sudo chmod -R 770 $$DIR_PATH; \
	sudo chmod g+s $$DIR_PATH

# Ask for user confirmation before running
# in a target that uses this confirm you call with confirm=y to skip the prompt
.PHONY: confirm
confirm:
ifeq ($(confirm),y)
	@echo "Skipping confirmation as 'confirm=y' was specified."
else
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]
endif
