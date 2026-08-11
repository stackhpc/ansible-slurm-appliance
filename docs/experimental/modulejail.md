# Limiting the loadable module list to mitigate future CVEs

There has been multiple instances of CVEs found in less-used kernel modules these past months.

Mitigating the vulnerability is as simple as adding it to [kernel_modules_vulnerable_denylist](../../environments/common/inventory/group_vars/all/kernel_modules.yml)
and re-running the `ansible/mitigations.yml` playbook.

But it doesn't protect the system in two cases:

- the attacker tricked an admin into loading the vulnerable module before the vulnerability is known;
- the attacker ran a command that automatically loaded the module (eg. sctp_diag is loaded by the `ss -S` command).

We propose to be proactive and ban any unused module at the time from being loaded.

This has been integrated using the [modulejail](https://github.com/jnuyens/modulejail) script.

## Using modulejail

1. add hosts in the `modulejail_sample_hosts` group in your staging inventory
2. `ansible-playbook -D ansible/adhoc/modulejail.yml`:
   2.1 installs the modulejail script
   2.2 collects all loaded modules to constitute a whitelist of needed modules
   2.3 runs modulejail in dry-mode with this whitelist and collects the result
   2.4 generates the `kernel_modules_modulejail_denylist` variable in `environments/staging/inventory/group_vars/all/modulejail.yml`.
3. keep `environments/staging/inventory/group_vars/all/modulejail.yml` under Git control.
4. `ansible-playbook -D ansible/mitigations.yml` to deploy the new deny list on all nodes
5. Rebuild the image to include the new deny list, or ensure ansible/mitigations.yml is run on newly provisionned nodes.

## Enabling a module

1. if a module happens to be needed, edit `/etc/modprobe.d/appliance.conf` to remove the 2 lines containing it;
   you can now `modprobe` the module.
2. add it to `additional_modules` in `ansible/adhoc/modulejail.yml` and rerun the it
3. run the `ansible/mitigations.yml` playbook to remove it from `/etc/modprobe.d/appliance.conf` on all hosts.

## Discussion

- Should mitigations.yml be included in compute-init and kernel_modules.yml exported?
- 3-steps build, run modulejail, rebuild image is heavy.
- should the `modulejail.yml` variable file be in site or current inventory?
