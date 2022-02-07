# cluster_dataset_manager
Automatically creates datasets such as /project spaces on Eagle.

Create encrypted file for database variables
===

Create the file in the same path/directory as cluster_dataset_manager.yml.

```
$ ansible-vault create allocation_vars_crypted.yml
---
ALLOCATIONS_DB_USER: "EXAMPLE"
ALLOCATIONS_DB_PW: "EXAMPLE"
```

Dependencies
===

Install Ansible.

Usage
===

```
sccmgr@hpcjump$ ansible-playbook -s cluster_dataset_manager.yml --check
```
