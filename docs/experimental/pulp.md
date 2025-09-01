# Pulp Server

In order to ensure reproducible builds, the appliance can build images using repository mirrors from StackHPC's "Ark" Pulp server. The appliance can sync relevant repositories to a local Pulp server which will then be used instead of Ark.

## Deploying/configuring Pulp Server

### Deploying a Pulp server
A playbook is provided to install and configure a Pulp server on a given host. Admin credentials for this server are automatically generated through the `ansible/adhoc/generate-passwords.yml` playbook. To use this, create an inventory file
defining a group `pulp_server` containing a single host, which requires at least 2 vCPUs and 4GB RAM. The group should be defined in your `site` environment's inventory so that a single Pulp server is shared between all environments and 
the same snapshots are tested in staging and production.
Deploying and syncing Pulp has been tested on an RL9 host. The hostvar `ansible_host` should be defined, giving the IP address Ansible should use for ssh. For example, you can create an ini file at `environments/site/inventory/pulp` with the contents:

```
[pulp_server]
pulp_host ansible_host=<VM-ip-address>
```

> [!WARNING] 
> The inventory hostname cannot conflict with group names i.e can't be called `pulp` or `pulp_server`.

Once complete, it will print a message giving a value to set for `appliances_pulp_url` (see example config below), assuming the `ansible_host` address is also the address the cluster
should use to reach the Pulp server.

Note access to this server's content isn't authenticated so this assumes the `pulp_server` host is not externally reachable.

### Using an existing Pulp server
An existing Pulp server can be used to host Ark repos by overriding `pulp_site_password` and `appliances_pulp_url` in the target environment. Note that this assumes the same configuration as the appliance deployed Pulp i.e no content authentication.

## Syncing Pulp content with Ark

If the `pulp` group is added to the Packer build groups, the local Pulp server will be synced with Ark on build. You must authenticate with Ark by overriding `pulp_site_upstream_username` and `pulp_site_upstream_password` with your vault encrypted Ark dev credentials. `dnf_repos_username` and `dnf_repos_password` must remain unset to access content from the local Pulp.

Content can also be synced by running `ansible/adhoc/sync-pulp.yml`. By default this syncs repositories for the latest version of Rocky supported by the appliance but this can be overridden by setting extra variables for `pulp_site_target_arch`, `pulp_site_target_distribution` and `pulp_site_target_distribution_version`.

## Example config in site variables

```
# environments/site/inventory/group_vars/all/pulp_site.yml:
appliances_pulp_url: "http://<pulp-host-ip>:8080"
pulp_site_upstream_username: <Ark-username>
pulp_site_upstream_password: <Ark-password>
```
