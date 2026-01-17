# Provision Java Role

This Ansible role installs OpenJDK on Linux (Debian/Ubuntu and RedHat/Rocky/CentOS) and Microsoft OpenJDK on Windows. It supports installing multiple JDK versions and switching between them using the system alternatives mechanism.

## Requirements

- Control node: Python 3.9+, Ansible 2.14+
- Linux targets: Debian/Ubuntu or RedHat/Rocky/CentOS with package manager access
- Windows targets: Windows host accessible over WinRM with administrator rights

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

## Local Testing

This role uses Test Kitchen with Vagrant for testing.

### Prerequisites

- Vagrant
- VirtualBox (or other supported provider)
- Ruby with Bundler
- kitchen-ansible gem

### Available Make Targets

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

## Supported Platforms

| Platform | Box |
|----------|-----|
| Ubuntu 24.04 | `hashicorp-education/ubuntu-24-04` |
| Rocky Linux 9 | `bento/rockylinux-9` |
| Windows 11 | `stromweld/windows-11` |

## License

BSD-3-Clause.
