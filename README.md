# Provision Tomcat Role

This Ansible role installs Apache Tomcat on Windows hosts via Chocolatey. It is intentionally small: the expectation is that the companion `windows-base` role has already installed/configured Chocolatey so this role can focus purely on fetching the Tomcat package.

## Requirements

- Control node: Python 3.9+, Ansible 2.14+ with the `chocolatey.chocolatey` collection.
- Target node: Windows host accessible over WinRM with administrator rights.
- Chocolatey must already be installed; run the `windows-base` role first if needed.

## Role Variables

The role currently installs the Chocolatey package named `tomcat` with the arguments `-f -y`. If you need a different package/version, edit `tasks/install-Windows-tomcat.yml` (or override those values through `set_fact` before including the role).

## Tasks Overview

`tasks/install-Windows-tomcat.yml` wraps a single block:

1. Calls `win_chocolatey` with the configured package name and args.
2. Registers the result for later use (e.g., downstream roles can inspect `tomcat_installation.changed`).

The block executes only when `ansible_facts.os_family == 'Windows'` (set in `tasks/main.yml`).

## Example Playbook

```yaml
---
- hosts: windows
  gather_facts: yes
  roles:
    - windows-base      # ensures Chocolatey + PATH
    - provision-tomcat
```

## Local Testing

Use the shared Test Kitchen workflow from the repo root:

```bash
make test-win11
# or on Windows PowerShell
set KITCHEN_YAML=.kitchen-win.yml
make test-win11
```

Kitchen spins up the Windows 11 Vagrant box, runs `windows-base`, then applies this role so you can validate the Tomcat Chocolatey install.

## License

BSD-3-Clause.
