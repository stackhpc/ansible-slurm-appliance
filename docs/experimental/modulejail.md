# Limiting the loadable module list to mitigate future CVEs

There have been multiple instances of CVEs found in less-used kernel modules these past months.

Mitigating the vulnerability is as simple as adding it to [kernel_modules_vulnerable_denylist](../../environments/common/inventory/group_vars/all/kernel_modules.yml)
and re-running the `ansible/mitigations.yml` playbook to patch your live cluster and/or rebuilding the image.

However this does not protect the system in two cases:

- The attacker tricked an admin into loading the vulnerable module before the vulnerability is known.
- The attacker ran a command that automatically loaded the module (eg. sctp_diag is loaded by the `ss -S` command).

We propose to be proactive and ban any unused module at the time from being loaded.

This has been integrated using the [modulejail](https://github.com/jnuyens/modulejail) script.

## Using modulejail

Add hosts in the `modulejail_sample_hosts` group in your staging inventory.

Pick one from each hardware/VM kind to cover all combinations of loaded modules.

```yaml
# environments/staging/inventory/groups
[modulejail_sample_hosts]
staging-control
staging-baremetal-cpu-1
staging-baremetal-other-vendor-cpu-1
staging-vgpu-1
staging-baremetal-gpu-1
```

On smaller deployments it can be run on all nodes:

```yaml
# environments/staging/inventory/groups
[modulejail_sample_hosts:children]
cluster
```

Then, run `ansible-playbook --diff ansible/adhoc/modulejail.yml`. It:

1. installs the modulejail script on sample nodes;
2. collects all loaded modules to compute an allowlist of needed modules;
3. runs modulejail in dry-run mode with this allowlist and collects the result;
4. generates the `kernel_modules_modulejail_denylist` variable in `environments/site/inventory/group_vars/all/modulejail_denylist.yml`.

Finally, remember to keep `environments/site/inventory/group_vars/all/modulejail_denylist.yml` under Git control.

## Applying the denylist

We deploy the new denylist and remove modules by running the `ansible/mitigations.yml` playbook as part of `ansible/site.yml`
(use `--tags kernel_modules` to not do anything else).

The `kernel_modules` inventory group covers the whole `cluster`, so all active nodes are patched with the new denylist at this moment.

### Without compute_init

Without `compute_init` usage on a cluster, nodes are inactive until a first run of the `ansible/site.yml` playbook to configure them.
In particular they are not accessible to non-admin users before that, so any LPE vulnerability would be inapplicable.

As soon as they are provisionned, we run `ansible/site.yml` to configure them and apply the module denylist.

### With compute_init

The `kernel_modules_denylist` variable is saved in the hostvars for each compute node on the cluster export of
the control node when we run the compute_init `export.yml` tasks. This is run as part of `ansible/site.yml`
(in `ansible/final.yml`).

We submit Slurm jobs to upgrade compute nodes. When they boot, they fetch the current `kernel_modules_denylist` and
apply it as part of compute_init.

## Enabling a module

1. If a module happens to be needed, edit `/etc/modprobe.d/appliance.conf` to remove the 2 lines containing it;
   you can now `modprobe` the module. This is a stopgap measure.
2. For a permanent fix, add it to the `modulejail_allowlist_modules_extra` in `environments/site/inventory/group_vars/all/modulejail.yml`
   and rerun `ansible/adhoc/modulejail.yml` to have the module removed from `kernel_modules_modulejail_denylist`.
3. Run the `ansible/mitigations.yml` playbook to update `/etc/modprobe.d/appliance.conf` on all hosts.

## Sample workflow to do an appliance update

With a different kernel version there might be changes to modules needed to run on the cluster.

### Preparation on staging

1. Merge the update's tag
2. Build an image (current denylist will be propagated to the image)
3. Deploy and configure staging
4. Run `ansible/adhoc/modulejail.yml` to create the new `kernel_modules_denylist`
5. Apply the new denylist in staging and test it. In particular, it is advised to confirm that nodes still work after a reboot.

### Deployment in production

#### Deployment on compute_init clusters

1. Redeploy control and login nodes with the new image using OpenTofu.
2. Run `ansible/site.yml` to patch all active nodes (with the new or the old image) and export the `kernel_modules_denylist` to
   the control host (`ansible-playbook --diff ansible/site.yml --tags compute_init,kernel_modules`).
3. Run `ansible/adhoc/rebuild-via-slurm.yml` to schedule upgrade of compute nodes.
4. When compute nodes boot they always apply the value of `kernel_modules_denylist` that was saved on the cluster
   export of the control node.

### Deployment on clusters without compute-init

1. Redeploy control and login nodes with the new image using OpenTofu.
2. Run `ansible/site.yml` to patch all active nodes (with the new or the old image).
3. Each time a node is reprovisionned with the new image, `ansible/site.yml` is rerun to configure it and it applies
   the latest `kernel_modules_denylist`.

### Limitations

Edge cases can arise when having a mixture of nodes running the old and new image.

For instance when a module had to be blocked in a previous version but is needed on the new version, one must be careful
to not remove the module from the denylist of existing nodes, but remove it from the cluster export, to be picked when nodes are rebuilt.
