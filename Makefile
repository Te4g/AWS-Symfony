.SILENT:

##
## Dev
## -----
##

install: ## Install project
	# Download the latest versions of the pre-built images.
	docker-compose pull
	# Rebuild images.
	docker-compose up --build -d

start: ## Start project
	# Running in detached mode.
	docker-compose up -d --remove-orphans --no-recreate

stop: ## Stop project
	docker-compose stop

logs: ## Show logs
	# Follow the logs.
	docker-compose logs -f

reset: ## Reset all (use it with precaution!)
	make uninstall
	make install

uninstall:
	make stop
	# Kill containers.
	docker-compose kill
	# Remove containers.
	docker-compose down --volumes --remove-orphans

##
## Frontend specific
## -----
##

back-ssh: ## Connect to the container in ssh
	docker exec -it aws-symfony_php_1 sh

##
## Tests & CI
## -----
##

test: ## Run all tests
	make cs-fix
	make stan
	make sniffer
	make security

cs: ## Run php cs fixer
	docker-compose exec php ./vendor/friendsofphp/php-cs-fixer/php-cs-fixer fix --dry-run --stop-on-violation --diff

cs-fix: ## Run php cs fixer and fix errors
	docker-compose exec php ./vendor/friendsofphp/php-cs-fixer/php-cs-fixer fix

stan: ## Run php stan
	docker-compose exec php ./vendor/phpstan/phpstan/phpstan analyse -c phpstan.neon src tests --level 5

sniffer: ## Run php code sniffer
	docker-compose exec php ./vendor/bin/phpcbf -p -v

security: ## Check for dependencies known vulnerabilities
	docker run --rm -v $(shell pwd):$(shell pwd) -w $(shell pwd) symfonycorp/cli check:security

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
