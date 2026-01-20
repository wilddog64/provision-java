# Provision Java Role

This Ansible role installs OpenJDK on Linux (Debian/Ubuntu and RedHat/Rocky/CentOS) and Microsoft OpenJDK on Windows. It supports installing multiple JDK versions and switching between them using the system alternatives mechanism.

## Requirements

- Control node: Python 3.9+, Ansible 2.14+
- Linux targets: Debian/Ubuntu or RedHat/Rocky/CentOS with package manager access
- Windows targets: Windows host accessible over WinRM with administrator rights

## Dependencies

Install required Ansible collections (installs to `./collections`):

```bash
# Use Make (recommended)
make deps

# Or manually
ansible-galaxy collection install ansible.windows chocolatey.chocolatey -p ./collections
```

## Role Variables

### Linux & Windows

| Variable | Default | Description |
|----------|---------|-------------|
| `jdk_version` | `21` | Default JDK version to install and set as active |
| `jdk_versions` | `[]` | List of additional JDK versions to install |

### Windows Only

| Variable | Default | Description |
|----------|---------|-------------|
| `java_install_base_dir` | `C:/java` | Base installation directory |
| `java_symlink_name` | `current` | Symlink name pointing to active Java version |
| `java_keep_versions` | `10` | Number of old Java versions to keep (0 = keep all) |
| `java_temp_dir` | `C:/temp` | Temporary directory for downloads |

## Features

### Linux
- Installs distribution-provided OpenJDK packages
- Supports multiple JDK versions via `jdk_versions` list
- Uses `update-java-alternatives` (Debian) or `alternatives` (RedHat) to switch versions
- Sets `JAVA_HOME` in `/etc/profile.d/java.sh`

### Windows
- Downloads and installs Microsoft OpenJDK
- Supports upgrade/downgrade between versions
- Manages symlink for consistent `JAVA_HOME` path
- Automatic cleanup of old versions based on retention policy
- Sets `JAVA_HOME` environment variable system-wide

## Example Playbook

### Single JDK Version

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: provision-java
      vars:
        jdk_version: 21
```

### Multiple JDK Versions

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: provision-java
      vars:
        jdk_versions:
          - 17
          - 21
        jdk_version: 21  # Set JDK 21 as default
```

### Switch Default Version

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: provision-java
      vars:
        jdk_versions:
          - 17
          - 21
        jdk_version: 17  # Switch default to JDK 17
```

## Command Line Usage

### Run with ansible-playbook

```bash
# Install JDK 21 (default)
ansible-playbook -i inventory playbook.yml

# Install multiple versions with JDK 17 as active
ansible-playbook -i inventory playbook.yml \
  -e '{"jdk_versions": [17, 21], "jdk_version": 17}'

# Switch active version (assumes versions already installed)
ansible-playbook -i inventory playbook.yml \
  -e 'jdk_version=21'
```

### Run on localhost

```bash
ansible-playbook -i localhost, -c local playbook.yml \
  -e '{"jdk_versions": [17, 21], "jdk_version": 21}' \
  --become
```

### Example inventory file

```ini
[linux]
192.168.1.100 ansible_user=ubuntu ansible_become=yes

[redhat]
192.168.1.101 ansible_user=rocky ansible_become=yes
```

## Local Testing

This role supports both Vagrant and Test Kitchen for local testing.

### Validation

Run validation checks (linting, syntax):

```bash
make check
```

### Prerequisites

- Vagrant
- VirtualBox (or other supported provider)
- Ruby with Bundler (for Test Kitchen)
- kitchen-ansible gem (for Test Kitchen)

### Vagrant Testing

Quick local testing with Vagrant (default: Rocky Linux 9):

```bash
# Start VM with default versions (JDK 17 and 21, with 21 active)
make vagrant-up

# Re-provision to apply changes
make vagrant-provision

# SSH into VM to verify
make vagrant-ssh

# Destroy VM
make vagrant-destroy
```

#### Test on Different Distros

Use distro-specific targets or scripts:

```bash
# Ubuntu 24.04
make vagrant-ubuntu-up
make vagrant-ubuntu-provision
make vagrant-ubuntu-ssh
make vagrant-ubuntu-destroy

# Rocky Linux 9
make vagrant-rocky-up
make vagrant-rocky-provision
make vagrant-rocky-ssh
make vagrant-rocky-destroy

# Or use scripts directly
./bin/vagrant-ubuntu up
./bin/vagrant-rocky up
```

#### Custom JDK Versions

Use environment variables to customize which versions to install:

```bash
# Install JDK 11, 17, 21 with 17 as active
JDK_VERSIONS=11,17,21 JDK_VERSION=17 vagrant up

# Or use Makefile target
make vagrant-multi JDK_VERSIONS=11,17,21 JDK_VERSION=17

# Switch active version without reinstalling
JDK_VERSION=11 vagrant provision
```

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `JDK_VERSIONS` | `17,21` | Comma-separated list of versions to install |
| `JDK_VERSION` | `21` | Version to set as active default |

### Test Kitchen

For comprehensive testing across multiple platforms:

```bash
# List all available targets
make help

# List kitchen instances
make list-kitchen-instances

# Test on specific platform (default suite)
make test-ubuntu-2404
make test-rockylinux9
make test-win11

# Test specific suite on platform
make test-multi-rockylinux9      # Install multiple JDK versions
make test-upgrade-ubuntu-2404    # Test version switching
make test-idempotence-rockylinux9

# Converge without destroying
make converge-rockylinux9
make converge-ubuntu-2404

# Destroy instances
make destroy-rockylinux9
make destroy-ubuntu-2404
```

### Test Suites

| Suite | Description |
|-------|-------------|
| `default` | Install JDK 21 only |
| `multi` | Install JDK 17 and 21, set 21 as default |
| `upgrade` | Install JDK 17 and 21, set 17 as default |
| `idempotence` | Verify idempotent behavior |

### Preflight Check

A preflight check runs automatically before `test` and `converge` targets to ensure the transfer size is reasonable (< 50MB). Run manually with:

```bash
make preflight
```

## Supported Platforms

| Platform | Box |
|----------|-----|
| Ubuntu 24.04 | `hashicorp-education/ubuntu-24-04` |
| Rocky Linux 9 | `bento/rockylinux-9` |
| Windows 11 | `stromweld/windows-11` |

## License

[MIT](LICENSE)
