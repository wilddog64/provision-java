# Technical Context

## Stack
- **Primary framework**: Ansible role
- **Languages**: YAML (Ansible), shell helpers, Ruby-based Test Kitchen ecosystem
- **Control node requirements**:
  - Python 3.9+
  - Ansible 2.14+

## Runtime Targets
- Linux:
  - Ubuntu/Debian family
  - RedHat/Rocky/CentOS family
- Windows:
  - Windows hosts managed over WinRM

## Dependency Model
- Ansible collections:
  - `ansible.windows`
  - `chocolatey.chocolatey`
- Ansible role dependency:
  - `linux-base` from `https://github.com/wilddog64/linux-base.git` (branch `main`)
- Python package requirements:
  - `ansible`
  - `pywinrm`

## Repository Tooling
- `Makefile` as primary DX entrypoint for:
  - dependency install (`make deps`)
  - lint/syntax checks (`make lint`, `make syntax`, `make check`)
  - Test Kitchen orchestration across suites/platforms
  - Vagrant workflows
- Test Kitchen configs:
  - `.kitchen.yml` (cross-platform, including Windows transport/provisioner overrides)
  - `.kitchen-win.yml` (Windows-host-oriented variant)
- Ansible configuration:
  - `ansible.cfg` with local `roles_path` and `collections_path`

## Notable Operational Constraints
- Keep transfer payloads small for kitchen runs (`preflight` max transfer size 50MB).
- Prefer environment-based secret injection (e.g., `ADO_PAT_TOKEN`); avoid committed plaintext secrets.
- Windows automation assumes WinRM connectivity and elevated operations where required.
