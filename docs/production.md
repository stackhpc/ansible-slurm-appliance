# Production Deployments

This page contains some brief notes about differences between the default/demo configuration, as described in the main [README.md](../README.md) and production-ready deployments.

- Create a site environment. Usually at least production, staging and possibly development environments are required. To avoid divergence of configuration these should all have an `inventory` path referencing a shared, site-specific base environment. Where possible hooks should also be placed in this site-specific environment.
- Vault-encrypt secrets. Running the `generate-passwords.yml` playbook creates a secrets file at `environments/$ENV/inventory/group_vars/all/secrets.yml`. To ensure staging environments are a good model for production this should generally be moved into the site-specific environment. It can be be encrypted using [Ansible vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) and then committed to the repository.
- Ensure created instances have accurate/synchronised time. For VM instances this is usually provided by the hypervisor, but if not (or for bare metal instances) it may be necessary to configure or proxy `chronyd` via an environment hook.
- Remove production volumes from OpenTofu control. In the default OpenTofu configuration, deleting the resources also deletes the volumes used for persistent state and home directories. This is usually undesirable for production, so these resources should be removed from the OpenTofu configurations and manually deployed once. However note that for development environments leaving them under OpenTofu control is usually best.
- Configure Open OpenOndemand - see [specific documentation](openondemand.README.md).
