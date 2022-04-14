default: fmt tests

infra-up:
	sudo docker-compose -f infra/docker/docker-compose.yml up -d
	./infra/docker/await-healthy.sh
	cd infra/terraform/ && \
	terraform init && \
	terraform apply -auto-approve && \
	cd -

infra-down:
	cd infra/terraform/ && \
	terraform destroy -auto-approve && \
	cd -
	sudo docker-compose -f infra/docker/docker-compose.yml down -v

integration-tests:
	terraform test

tests: infra-up integration-tests infra-down

lint:
	terraform fmt -recursive -check

fmt:
	terraform fmt -recursive
	terraform-docs markdown table --output-file README.md --output-mode inject .
