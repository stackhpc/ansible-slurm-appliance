# Caas cluster

Environment for Azimuth CaaS Slurm. This is also used for CI and may be manually deployed
for debugging and development. It should *not* be used for a non-CaaS Slurm cluster.

Non-standard things for this environment:
- The `activate` script is provided *only* for development/debugging.
- `ansible.cgf` is provided in the repo root, as expected by the caas operator.
- `ANSIBLE_INVENTORY` is set in the cluster type template, using a path relative to the 
  runner project directory:

        azimuth_caas_stackhpc_slurm_appliance_template:
        ...
        envVars:
            ANSIBLE_INVENTORY: environments/common/inventory,environments/.caas/inventory

    Ansible then defines `ansible_inventory_sources` which contains absolute paths, and 
    that is used to derive the `appliances_environment_root` and 
    `appliances_repository_root`.

It is also used for CI, and may be manually deployed for development/debugging as follows:
  
    . venv/bin/activate
    . enviroments/.caas/activate # NB: CI_CLOUD may need changing
    ansible-playbook ansible/site.yml #-e cluster_state=absent

Once deployed or at least the `cluster_infra` role has finished, individual or ad-hoc
playbooks may be run as usual.
