# Project Brief: provision-java

## Purpose
`provision-java` is an Ansible role that installs and configures Java across Linux and Windows hosts with a consistent interface.

## Primary Goals
- Install OpenJDK on Linux (Debian/Ubuntu and RedHat/Rocky/CentOS).
- Install Microsoft OpenJDK on Windows.
- Support single or multiple JDK versions.
- Set a chosen active/default JDK version.
- Ensure validation via lint/syntax checks and local test workflows (Vagrant + Test Kitchen).

## Scope
- Role implementation in `tasks/`, `vars/`, `defaults/`, `handlers/`, `meta/`.
- Local/dev validation and test orchestration in `Makefile`, `.kitchen*.yml`, `tests/`, and helper scripts in `bin/`.

## Key Dependencies
- Ansible >= 2.14
- Python 3.9+
- Collections: `ansible.windows`, `chocolatey.chocolatey`
- External role: `linux-base` (installed from Git)

## Current Baseline
- Role entrypoint: `tasks/main.yml` with OS-specific include flow.
- Linux path installs package-manager JDKs and sets alternatives/JAVA_HOME.
- Windows path installs Microsoft JDK zip, manages symlink, PATH, JAVA_HOME, and retention cleanup.
