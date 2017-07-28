# provision-oracle-java

an Ansible role that will install oracle java and jce

## Requirements

* Python 2.7 or greater
* Ansible 2.0 or greater

## Role Variables
These variables control how provision-oracle-java behavior

### platform indedepend variables

* oracle_java_version is a major oracle java version, i.e. 7, 8, ...
* oracle_jce_url is where to download oracle jce package
* oracle_jce_home is where oracle jce to be extracted to
* require_oracle_java is a boolean flag to determine if java need to be installed. Default is yes.

### platform specific variables

#### vars/RedHat.yml - for RedHat family OSes
* oracle_java_version_update is what update you want to have
* oracle_java_version_build is what build will it be

## Dependencies


## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    ---
    - hosts: all
      become: yes
      roles:
    	- provision-oracle-java

## Command Line Usage

* ansible-playbook -vv -i tests/inventory -l test-jenkins -k tests/playbook.yml will apply playbook to a label test-jenkins defines in tests/inventory file. It will ask password for ssh session, and output level 2 verbosity to console

## License

BSD
