# sre-ansible
A flexible Ansible automation repository for provisioning, configuring, deploying, and maintaining diverse services


# Paths Importantes
roles/       → lógica reutilizable
playbooks/   → flujos de ejecución
services/    → definiciones específicas de cada servicio
inventories/ → datos por ambiente y servidor

# Instalar las collections

```bash
ansible-galaxy collection install -r requirements.yml -p .ansible/collections
```

# Vault

Las variables enriptadas por el vault se referencian asi

```
grafana_admin_password: "{{ vault_grafana_admin_password }}"
```

```bash
ansible-playbook playbooks/deploy_service.yml \
  -i inventories/dev \
  --ask-vault-pass \
  -e service_name=grafana
```

# Lanzando los playbocks

```
ansible-playbook playbooks/deploy_service.yml \
  -i inventories/dev \
  --limit vm-prod-01 \
  -e service_name=uptime_kuma
```

# Agregar un nuevo servicio al repo


```
mkdir -p services/nuevo_servicio
touch services/nuevo_servicio/vars.yml
touch services/nuevo_servicio/compose.yml.j2
touch services/nuevo_servicio/env.j2
touch services/nuevo_servicio/README.md
```

# Uso del make file

```bash
make collections
make lint
make deploy service=uptime_kuma
```

# Convenciones

1. Los roles no deben tener datos de producción hardcodeados.
2. Los servicios no deben tener secretos en texto plano.
3. Todo servicio debe tener README.md.
4. Todo servicio debe declarar puertos, volúmenes, dominios y backup.
5. Toda variable sensible debe venir de vault.
6. Los playbooks deben ser pequeños y orientados a una operación.
7. Los roles deben ser idempotentes.
8. Evita usar shell/command si existe un módulo Ansible.
9. Usa tags por área: bootstrap, docker, certs, deploy, backup, security.
10. Cada servicio Docker Compose debe poder desplegarse con el mismo playbook genérico.


# Algunos Primeros Pasos

```bash
mkdir ansible-sre-toolkit
cd ansible-sre-toolkit

git init

mkdir -p \
  inventories/{dev,staging,prod}/{group_vars,host_vars} \
  playbooks/maintenance \
  roles/{common_base,users_ssh,security_baseline,firewall,docker_engine,compose_project,reverse_proxy,certificates,backup,monitoring_agent,logrotate}/{defaults,tasks,handlers,templates,files,meta} \
  services/{uptime_kuma,portainer,traefik} \
  docs \
  scripts \
  tests/molecule
```


```bash
touch README.md
touch ansible.cfg
touch requirements.yml
touch requirements-dev.txt
touch Makefile
touch .gitignore
touch .pre-commit-config.yaml

touch inventories/dev/hosts.yml
touch inventories/prod/hosts.yml

touch playbooks/bootstrap_vm.yml
touch playbooks/install_docker.yml
touch playbooks/deploy_service.yml
touch playbooks/certificates.yml
touch playbooks/site.yml
```
