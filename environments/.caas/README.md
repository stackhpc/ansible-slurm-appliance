# Caas cluster

Environment for default Azimuth Slurm. This is not intended to be manually deployed.

Non-standard things for this environment:
- There is no activate script.
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
