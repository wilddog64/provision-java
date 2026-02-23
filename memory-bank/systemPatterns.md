# System Patterns

## Architectural Style
- **Ansible role-centric design**: one reusable role with OS-conditional execution.
- **Task decomposition by concern**:
  - `tasks/main.yml`: orchestration and OS branching
  - `tasks/install-Linux-java.yml`: Linux Java package install + alternatives + validation
  - `tasks/install-Windows-java.yml`: Windows Java zip install + symlink + validation + cleanup
  - `tasks/packages.yml` and `tasks/systemd-resolved.yml`: Linux prerequisites/network stabilization

## Execution Flow Pattern
1. Gather facts and OS-specific vars.
2. For Linux:
   - include `linux-base` role
   - optional resolver fixup (`systemd-resolved`)
   - install prerequisite packages
   - install Java and set active version
3. For Windows:
   - compute install paths and download URL
   - install/upgrade Microsoft JDK
   - maintain stable symlink and system env vars
   - enforce version retention

## Configuration Patterns
- **Version selection model**:
  - `jdk_versions` = optional list of additional versions
  - `jdk_version` = active/default version
  - Linux computes `all_jdk_versions` as unique union of both
- **OS package naming abstraction** via vars:
  - Debian: `openjdk-<version>-jdk`
  - RedHat: `java-<version>-openjdk-devel`

## Validation/Quality Patterns
- Assertions included directly in role tasks to verify:
  - `JAVA_HOME` existence
  - binaries present/executable
  - active Java/javac version matches requested default
- Local quality gates in Makefile:
  - lint (`ansible-lint`)
  - syntax check (`ansible-playbook --syntax-check`)
  - aggregate `check`
- Test matrix with Test Kitchen suites (`default`, `multi`, `upgrade`, `idempotence`) across Linux and Windows.

## Security & Operational Patterns
- No plaintext secrets in role defaults for credential material.
- PAT/secret guidance uses environment injection (`ADO_PAT_TOKEN`) rather than committed values.
- Test Kitchen template includes commented `vault_password_file` stub, aligning with vault-backed secret handling.
