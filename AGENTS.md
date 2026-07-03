# AGENTS.md

## Repo Shape
- This is an Ansible repo for provisioning hosts and deploying Docker Compose services.
- `ansible.cfg` sets default inventory to `inventories/dev/hosts.yml`, but the repo currently only includes `inventories/dev/hosts.yml.example`; commands without `-i` need a real local inventory file.
- Collections are installed repo-locally under `.ansible/collections`; use `make collections` before syntax checks or playbook runs.
- `playbooks/site.yml` imports only `bootstrap_vm.yml` and `install_docker.yml`; service deployment is separate via `playbooks/deploy_service.yml`.
- Bootstrap currently targets Ubuntu/Debian hosts and is split across `common_base`, `users_ssh`, `security_baseline`, and `firewall` roles.

## Commands
- Install Ansible collections: `make collections`.
- Lint YAML and Ansible: `make lint` (`yamllint .` then `ansible-lint .`).
- Syntax-check the site playbook: `make syntax`.
- Ping default inventory hosts: `make ping`.
- Bootstrap dev inventory: `make bootstrap`.
- Install Docker on dev `docker_hosts`: `make docker`.
- Deploy one service: `make deploy service=uptime_kuma` or `ansible-playbook playbooks/deploy_service.yml -i inventories/dev -e service_name=uptime_kuma`.
- Vault-protected runs need `--ask-vault-pass`, e.g. add it to the deploy command when service vars reference `vault_*` values.
- `requirements-dev.txt` is currently empty, so `make install` does not install `yamllint`, `ansible-lint`, or Ansible itself.

## Service Deployment Model
- Each service lives under `services/<service_name>/` and is loaded by `deploy_service.yml` through `include_vars: ../services/{{ service_name }}/vars.yml`.
- A service vars file must set at least `compose_project_name` and `compose_template_src`; `compose_env_template_src` is optional.
- `compose_project` renders the compose template to `{{ compose_base_dir }}/{{ compose_project_name }}/compose.yml` and optional env template to `.env`, then runs `community.docker.docker_compose_v2`.
- `compose_base_dir` is defined for dev Docker hosts in `inventories/dev/group_vars/docker_hosts.yml` as `/opt/compose`.
- The existing `uptime_kuma` service uses template paths like `../../services/uptime_kuma/docker-compose.yml.j2`; follow that pattern unless the role is changed.

## Conventions And Gotchas
- Bootstrap admin users are expected from inventory vars such as `bootstrap_admin_users`; `inventories/dev/group_vars/all.yml.example` shows the shape and should be copied/adapted locally before running bootstrap.
- The bootstrap firewall role uses persisted permissive `iptables` rules via `iptables-persistent`/`netfilter-persistent`, not `ufw`; it intentionally leaves INPUT/FORWARD open so Docker-managed rules work and firewall can be tightened manually later.
- `install_docker.yml` targets `docker_hosts` and uses `roles/docker_engine` with Docker's official apt repository; it installs the Compose v2 plugin and adds `bootstrap_admin_users` to the `docker` group when those vars exist.
- Do not hardcode production data or plaintext secrets in roles or service files; sensitive vars should come from Ansible Vault and be referenced as `vault_*` values.
- Prefer Ansible modules over `shell`/`command`; roles are expected to be idempotent.
- Keep playbooks small and operation-oriented; reusable logic belongs in roles, service-specific data/templates belong in `services/`.
- README lists expected roles beyond the current implementation; `monitoring_agent` and similar roles are still not present unless added later.
