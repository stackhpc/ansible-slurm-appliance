# Terraform

## Dependencies

- [terraform](https://www.terraform.io/)
- libvirt
- [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt)

Currently you must install the plugin [manually](https://github.com/dmacvicar/terraform-provider-libvirt/blob/3679e7c8249a2975dedcc236fda2d1e51306f48b/docs/migration-13.md),
but it will be added to the hashicorp regsitry soon.

## Provisioning

To create a cluster:

    [will@juno terraform]$ terraform init

    [will@juno terraform]$ terraform apply

## Destorying the cluster

When finished, run:

    terraform destroy --auto-approve
