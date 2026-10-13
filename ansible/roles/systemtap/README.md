# SystemTap

Installs SystemTap and allows configuring probes to be compiled to modules and
optionally loaded on boot. This provides a way to roll out SystemTap-based CVE
mitigations, such as the mitigation suggested for
[RefluXFS by Red Hat](https://access.redhat.com/security/cve/cve-2026-64600).

## Usage

By default SystemTap is installed in appliance images. SystemTap probes aren't
compiled into modules and run during a `site.yml` run, instead the role's
runtime functionality in `tasks/configure.yml` is triggered by running
`ansible/adhoc/configure-stap-probes.yml`. This is because the role was designed
to be able to deploy SystemTap probes to mitigate CVEs on a running appliance
without the need to reimage compute nodes when the appliance is configured to
use
[Slurm controlled rebuilds](../../../docs/experimental/slurm-controlled-rebuild.md)
for upgrades. Running the ad hoc playbook compiles and loads configured scripts
on nodes in the `systemtap` group, which by default are nodes where users have
shell access or can run workloads:

```ini
# environments/site/inventory/groups
[systemtap:children]
login
compute
```

Probes can be configured to run on additional hosts by adding them as a child
of the group.

## Role variables

- `systemtap_scripts`: Optional list of mappings defining systemtap scripts to
  be compiled to modules and run, with keys:
  - `name`: Required str. Name of the module and systemd service to create for
    the script. Ensure this doesn't conflict with existing systemd services.
  - `script`: Required multiline str. Systemtap script to be compiled to module
    and run.
  - `persist`: Required bool. Indicates whether to load the script's module on
    boot. Use with caution for probes which have the potential to disrupt the
    cluster. Note that scripts with this variable set to `true` will persist on
    reboot but not reimage of the node.

  Note that the role will remove modules based on scripts which were previously
  defined in the list but are no longer present.

## Example configuration

For the example RefluXFS mitigation above, `systemtap_scripts` entry would be:

```yaml
- name: refluxfs # Arbitrary but unique identifier
  persist: true # Enable on boot
  script: |
    probe begin {
      printf("refluxfs mitigation loaded\n")
    }

    probe module("xfs").function("xfs_file_remap_range").call {
      $remap_flags = 0xffff
    }

    probe module("xfs").function("xfs_file_remap_range").return {
      $return = -95
    }

    probe end {
      printf("refluxfs mitigation unloaded\n")
    }
```
