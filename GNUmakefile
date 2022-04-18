default: fmt tests

infra-up:
	sudo docker-compose -f infra/docker/docker-compose.yml up -d
	./infra/docker/await-healthy.sh
	terraform -chdir=infra/terraform/ init
	terraform -chdir=infra/terraform/ apply -auto-approve

infra-down:
	terraform -chdir=infra/terraform/ destroy -auto-approve
	sudo docker-compose -f infra/docker/docker-compose.yml down -v

integration-tests:
	terraform test

tests: infra-up integration-tests infra-down

lint:
	terraform fmt -recursive -check

fmt:
	terraform fmt -recursive
	terraform-docs markdown table --output-file README.md --output-mode inject .
