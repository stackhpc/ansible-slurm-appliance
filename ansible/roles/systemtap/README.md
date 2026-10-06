# SystemTap

Installs SystemTap and allows configuring probes to be compiled to modules and
optionally loaded on boot. This provides a way to roll out SystemTap-based CVE
mitigations, such as the mitigation suggested for
[RefluXFS by RedHat](https://access.redhat.com/security/cve/cve-2026-64600).

## Enabling

By default configured SystemTap probes will run on the login and compute nodes,
where users are able to execute code.

```ini
# environments/site/inventory/groups
[systemtap:children]
login
compute
```

Probes can be configured to run on additional hosts by adding them as a child
of the group.

## Example configuration

For the example RefluXFS mitigation above, `systemtap_scripts` entry would be:

```yaml
- name: refluxfs   # Arbitrary but unique identifier
  persist: true    # Enable on boot
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

