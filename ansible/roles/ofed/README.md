# ofed

This role installs Mellanox OFED:
- It checks that the running kernel is the latest installed one, and errors if not.
- Installation uses the `mlnxofedinstall` command, with support for the running kernel
and (by default) without firmware updates.

As OFED installation takes a long time generally this should only be used during image build,
for example by setting:

```
environments/groups/<environment>/groups:
[ofed:children]
builder
```

# Role variables

See `defaults/main.yml`

Note ansible facts are required, unless setting `ofed_distro_version` and `ofed_arch` specifically.
