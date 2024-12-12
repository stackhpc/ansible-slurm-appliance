# Pulp Server

In order to ensure reproducible builds, the appliance can build images using repository mirrors from StackHPC's Ark Pulp server. The appliance will sync relevant repositories to local Pulp server which will be used for image builds. Using a local server can be enabled by adding `pulp` to the build groups and overriding `dnf_repos_repolist` to point at content hosted on the local server.

## Deploying/configuring Pulp Server

### Deploying a Pulp server
A playbook is provided to install and configure a Pulp server on a given host. Admin credentials for this server are automatically generated through the `ansible/adhoc/generate-passwords.yml' playbook. This can be run with
`ansible-playbook ansible/adhoc/deploy-pulp.yml -e "pulp_server=<host_ip>"`
This will print a Pulp endpoint which can be copied to your environments as appropriate. Ensure that the server is accessible on the specified port. Note that this server's content isn't authenticated so assumes the server is deployed behind a secure network.

### Using an existing Pulp server
An existing Pulp server can be used to host Ark repos by overriding `pulp_site_password` and `appliances_pulp_url` in the target environment. Note that this assumes the same configuration as the appliance deployed pulp i.e no content authentication.

## Syncing Pulp content with Ark

By default, the appliance will sync repos for the targetted distribution during build (can be disabled by setting `appliances_sync_pulp_on_build` to `false`). You must supply your Ark credentials, either by overriding `pulp_site_upstream_password` or setting environment variable `ARK_PASSWORD`. Content can also be synced by running `ansible/adhoc/sync-pulp.yml`, optionally setting extravars for `pulp_site_target_arch`, `pulp_site_target_distribution`, `pulp_site_target_distribution_version` and `pulp_site_target_distribution_version`.
