help: ## Help
		@echo "Hello!"

stop: ## Stop the container stack
		@echo "Stopping all containers..."
		docker compose stop && docker compose down
#		sudo docker compose stop && sudo docker compose down

build: ## Build the container stack
		@echo "Building containers..."
		docker compose build
#		sudo docker compose build

start: ## Start the container stack
		@echo "Building and Starting up containers..."
		make build && docker compose up -d
#		make build && sudo docker compose up -d

start_debug: ## Start the container stack in debuging mode
		@echo "Building and Starting up containers..."
		docker compose build --progress=plain && docker compose up -d

clean: ## CLean out unused docker & docker-compose files
		@echo "Removing all cached steps... [safe]"
		docker builder prune

		@echo "Removing unused docker files..."
		@echo "Please uncomment the next line here in Makefile!"
#		docker system prune -af
