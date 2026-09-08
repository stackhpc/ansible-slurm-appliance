# kernel_modules

This role applies a kernel module denylist.

It is compatible with compute_init: the denylist is exported to
the export share on the control host.

## Role Variables

A single variable is used by this module to populate `/etc/modprobe.d/appliance.conf`:

- `kernel_modules_denylist`: Optional str list, default `[]`. Modules to prevent from loading.

See [environments/common/kernel_modules.yml](../../environments/common/kernel_modules.yml) for
the default definition.

It is split in a list of modules known to be vulnerable (`kernel_modules_vulnerable_denylist`) and
unused modules we refrain from loading to reduce the attack surface (`kernel_modules_modulejail_denylist`).

See [docs/experimental/modulejail.md](../../docs/experimental/modulejail.md) for more info.
