.PHONY: install lint syntax collections ping

install:
	pip install -r requirements-dev.txt

collections:
	ansible-galaxy collection install -r requirements.yml -p .ansible/collections

lint:
	yamllint .
	ansible-lint .

syntax:
	ansible-playbook playbooks/site.yml --syntax-check

ping:
	ansible all -m ping

bootstrap:
	ansible-playbook playbooks/bootstrap_vm.yml -i inventories/dev

docker:
	ansible-playbook playbooks/install_docker.yml -i inventories/dev

deploy:
	ansible-playbook playbooks/deploy_service.yml -i inventories/dev -e service_name=$(service)
