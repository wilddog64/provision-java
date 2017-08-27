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
* oracle_jce7_url is where to download oracle jce 7 package (naming is out of whack)
* oracle_jce_home is where oracle jce to be extracted to
* require_oracle_java is a boolean flag to determine if java need to be installed. Default is yes.

### platform specific variables

#### vars/RedHat.yml - for RedHat family OSes
* oracle_java_version_update is what update you want to have
* oracle_java_version_build is what build will it be

#### os system specific variables (these variable loaded based on ansible_system fact)
* oracle_jce_home is a place where jce should be extracted to. Linux is /opt/java_jce-version and Windows is c:\opt\java_jce-version
* oracle_jce_download_location is a place where jce.zip file should be downladed to. Linux is /tmp and Windows is c:\temp

## Dependencies
* For windows, we need to have pywinrm package installed.

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    ---
    - hosts: all
      become: yes
      roles:
    	- provision-oracle-java

## Command Line Usage

* ansible-playbook -vv -l jenkins-slaves -k tests/playbook.yml will apply playbook to a label test-jenkins defines in tests/inventory file. It will ask password for ssh session, and output level 2 verbosity to console
* ansible-playbook -vvv -l w8x64s12-vm076.pd.local --extra-vars 'require_oracle_java=False oracle_java_version=8' -k tests/playbook.yml will install ```jce-8``` to a signle host w8x64s12-vm076.pd.local. Note that we have to specify oracle_java_version=8 in order to download jce 8

## Note
* a seperate inventory file for jenkins and jenkins slaves is created and set this in ansible.cfg file. You will need to pull the inventory repo from [here]sh://git@stash.bbpd.io/lid/ansible_inventory.git) in order for the above command to work
* a special logic is created for handling JCE 7, but nothing change from the commad line or playbook

## License

BSD
