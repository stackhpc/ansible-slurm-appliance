# gateway

Ensure a single default route via a specified address exists on boot.

**NB:** This role uses `linux-ansible-init` and is not run by the
`ansible/site.yml` playbook.

## Role variables

**NB:** This role has no Ansible variables. Setting the OpenTofu variable
`gateway_ip` to an IPv4 address will modify default routes as necessary to give
the instance a single default route via that address. The default route will
use the interface which has a CIDR including the gateway address.

Note that:

- If the correct default route already exists, no changes are made.
- If a default route exists on a different interface, that route will be deleted.
- If a default route exists on the same interface but using a different address,
  an assert will be raised to fail the `ansible-init` service - see logs using
  `journalctl -xue ansible-init`.

See [docs/networks.md](../../../docs/networks.md) for further discussion.

## Requirements

The image must include both this role and the `linux-ansible-init` role. This
is the case for StackHPC-built images. For custom images use one of the following
configurations during Packer build:

- Add `builder` into the `gateway` group in `environments/$ENV/inventory/groups`
- Add `gateway` to the `inventory_groups` Packer variable
