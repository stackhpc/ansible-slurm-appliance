# Pulp Server

In order to ensure reproducible builds, the appliance can build images using repository mirrors from StackHPC's "Ark" Pulp server. The appliance can sync relevant repositories to a local Pulp server which will then be used instead of Ark. Using a local Pulp can be enabled by adding `pulp` to the build groups and overriding `appliances_pulp_url` to point at the local Pulp's URL.

## Deploying/configuring Pulp Server

### Deploying a Pulp server
A playbook is provided to install and configure a Pulp server on a given host. Admin credentials for this server are automatically generated through the `ansible/adhoc/generate-passwords.yml' playbook. This can be run with
`ansible-playbook ansible/adhoc/deploy-pulp.yml -e "pulp_server=<target_host>"`
where `target_host` is any resolvable host. This will print a Pulp URL which can be copied to your environments as appropriate. Ensure that the server is accessible on the specified port. Note access to this server's content isn't authenticated so assumes the server is deployed behind a secure network.

### Using an existing Pulp server
An existing Pulp server can be used to host Ark repos by overriding `pulp_site_password` and `appliances_pulp_url` in the target environment. Note that this assumes the same configuration as the appliance deployed pulp i.e no content authentication.

## Syncing Pulp content with Ark

If the `pulp` group is added to the Packer build groups, the local Pulp server will be synced with Ark on build. You must supply your Ark credentials, either by overriding `pulp_site_upstream_password` or setting environment variable `ARK_PASSWORD`. Content can also be synced by running `ansible/adhoc/sync-pulp.yml`, optionally setting extravars for `pulp_site_target_arch`, `pulp_site_target_distribution`, `pulp_site_target_distribution_version` and `pulp_site_target_distribution_version`.
