# Pulp Server

In order to ensure reproducible builds, the appliance can build images using repository mirrors from StackHPC's "Ark" Pulp server. The appliance can sync relevant repositories to a local Pulp server which will then be used instead of Ark.

## Deploying/configuring Pulp Server

### Deploying a Pulp server
A playbook is provided to install and configure a Pulp server on a given host. Admin credentials for this server are automatically generated through the `ansible/adhoc/generate-passwords.yml` playbook. To use this, create an inventory file defining a group `pulp_server` containing a single host. The hostvar `ansible_host` should be defined, giving the IP address Ansible should use for ssh.

**TODO: should be RL9 (or RL8?)**
**TODO: add size required**
**TODO: example inventory file**

Once complete, it will print a message giving a value to set for `appliances_pulp_url`, assuming the `ansible_host` address is also the address the cluster
should use to reach the Pulp server.

**TODO: example config**

Note access to this server's content isn't authenticated so this assumes the `pulp_server` host is not externall reachable.

**TODO: You can actually do this using additional_nodes now, how would we make the pulp store persistant?**
**TODO: don't advise that, we want single server for all environments**
**TODO: Add a systemd unit to run pulp!**

### Using an existing Pulp server
An existing Pulp server can be used to host Ark repos by overriding `pulp_site_password` and `appliances_pulp_url` in the target environment. Note that this assumes the same configuration as the appliance deployed Pulp i.e no content authentication.

## Syncing Pulp content with Ark

If the `pulp` group is added to the Packer build groups, the local Pulp server will be synced with Ark on build. You must authenticate with Ark by overriding `pulp_site_upstream_username` and `pulp_site_upstream_password` with your vault encrypted Ark dev credentials. `dnf_repos_username` and `dnf_repos_password` must remain unset to access content from the local Pulp.

Content can also be synced by running `ansible/adhoc/sync-pulp.yml`. By default this syncs repositories for Rocky 9.5 <TODO: is this correct?>  but this can be overridden by setting extra variables for `pulp_site_target_arch`, `pulp_site_target_distribution`, `pulp_site_target_distribution_version` and `pulp_site_target_distribution_version_major`.
