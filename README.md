# Provision Oracle Java

An Ansible role that installs Oracle JDK and the matching Java Cryptography Extension (JCE) packages across Linux and Windows hosts. The role is primarily consumed by CI pipelines but can also be run locally through Test Kitchen + Vagrant for iterative testing.

## Requirements

- Python 3.9+ on the control node
- Ansible 2.14+ (role tested with 2.20)
- Access to the `ansible_inventory` repository referenced in `ansible.cfg`
- For Windows targets the controller must have `pywinrm` installed
- Optional local testing stack: Vagrant 2.3+, VirtualBox 7+, Test Kitchen 3.9+

## Configuration

The repository ships with an `ansible.cfg` tuned for faster fact gathering and a custom inventory location. If you keep the defaults you must clone the shared inventory repo into `$HOME/src/gitrepo/personal/ansible/ansible_inventory`.

Key defaults to be aware of:

```
fact_caching = jsonfile
fact_caching_connection = $HOME/.ansible/tmp
inventory = $HOME/src/gitrepo/personal/ansible/ansible_inventory/java-slave-inventory
roles_path = ..
```

## Role Variables

| Variable | Description |
| --- | --- |
| `oracle_java_version` | Major Oracle JDK version to install (e.g., `8`, `21`). |
| `oracle_java_version_update` | (RedHat) Update number for the chosen JDK version. |
| `oracle_java_version_build` | (RedHat) Build number for the chosen JDK version. |
| `oracle_jce_url` / `oracle_jce7_url` | Download URL for the JCE archive. |
| `oracle_jce_home` | Destination directory for extracted JCE files. Automatically varies by OS. |
| `oracle_jce_download_location` | Temporary path for the downloaded archive (per-OS). |
| `require_oracle_java` | Toggle full JDK installation. Defaults to `true`. |
| `require_jce` | Toggle JCE installation. Defaults to `true`. |

See `vars/` and `vars/*.yml` for platform-specific defaults.

## Example Playbook

```yaml
---
- hosts: all
  become: yes
  gather_facts: no
  roles:
    - windows-base
    - provision-java
```

Run it with:

```
ansible-playbook -vv -l <inventory_group> tests/playbook.yml
```

Add `-k`/`-K` if you need password prompts, and use `--extra-vars` to override role variables (e.g., `--extra-vars 'require_oracle_java=False oracle_java_version=8'`).

## Local Testing With Test Kitchen

Kitchen + Vagrant lets you exercise the role against disposable Linux and Windows guests. The default configuration lives in `.kitchen.yml` and targets:

- Ubuntu 24.04 (hashicorp-education box)
- Rocky Linux 9 (CentOS 8 box)
- Windows 11 (stromweld box, WinRM over HTTP)

Typical workflow on macOS/Linux hosts:

```
direnv allow  # if you rely on .direnv
rbenv exec kitchen test default-win11
# or simply: make test-win11
```

### Windows Host Note

Windows hosts already run WinRM listeners on ports 5985/5986, so VirtualBox cannot forward those ports directly. Use the alternate Kitchen config stored in `.kitchen-win.yml`, which forwards guest WinRM to high ports (25985/25986) and updates the Ansible connection vars accordingly.

On a Windows laptop run:

```
set KITCHEN_YAML=.kitchen-win.yml
bundle exec kitchen test default-win11
# or run: make test-win11
```

This variant still uses the `ansible_push` provisioner for the Windows platform so Ansible can communicate over WinRM instead of SSH.

#### Installing Ruby/Dependencies on Windows

Test Kitchen relies on Ruby and Bundler. On Windows the quickest path is Chocolatey:

```
choco install -y ruby --version=3.3.0
choco install -y git make
set PATH=C:\\tools\\ruby33\\bin;%PATH%
gem install bundler:4.0.3
bundle install
```

If you prefer RubyInstaller, download the matching Ruby 3.3.x build with MSYS2, install, and then run `ridk install` followed by `gem install bundler:4.0.3`. Either way, ensure `bundle exec kitchen` works before running the Make targets. Since rbenv is not available on native Windows, the Makefile automatically falls back to the standard `kitchen` executable when `rbenv` is missing.

> `choco install make` installs GNU Make (GnuWin). It behaves like GNU Make on Linux but runs under `cmd.exe`, so quote paths with spaces. If anything acts up, just run the Kitchen commands listed in the Makefile manually.

### Make Targets

The Makefile auto-selects `.kitchen.yml` on macOS/Linux and `.kitchen-win.yml` on Windows (override with `KITCHEN_YAML=...`). Handy shortcuts:

```
make test-win11          # kitchen test default-win11
make test-ubuntu-2404    # kitchen test default-ubuntu-2404
make test-rockylinux9    # kitchen test default-rockylinux9
make converge-<platform> # converge a single instance
make destroy-<platform>  # tear down a single instance
```

Replace `<platform>` with `win11`, `ubuntu-2404`, or `rockylinux9`.

## License

BSD
