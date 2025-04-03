# Pulp Server

In order to ensure reproducible builds, the appliance can build images using repository mirrors from StackHPC's "Ark" Pulp server. The appliance can sync relevant repositories to a local Pulp server which will then be used instead of Ark.

## Deploying/configuring Pulp Server

### Deploying a Pulp server
A playbook is provided to install and configure a Pulp server on a given host. Admin credentials for this server are automatically generated through the `ansible/adhoc/generate-passwords.yml` playbook. This can be run with
`ansible-playbook ansible/adhoc/deploy-pulp.yml -e "pulp_server=<target_host>"`
where `target_host` is any resolvable host. This will print a Pulp URL which can be copied to your environments as appropriate. Ensure that the server is accessible on the specified port. Note access to this server's content isn't authenticated so assumes the server is deployed behind a secure network.

### Using an existing Pulp server
An existing Pulp server can be used to host Ark repos by overriding `pulp_site_password` and `appliances_pulp_url` in the target environment. Note that this assumes the same configuration as the appliance deployed pulp i.e no content authentication.

## Syncing Pulp content with Ark

The dnf repo snapshots used are defined in `environments/common/inventory/group_vars/all/timestamps.yml`
and may change with each release.

The current snapshots can be synced from Ark to the local Pulp by running `ansible/adhoc/sync-pulp.yml`.
By default this syncs repositories for Rocky `9.5`, but this can be overriden
if necessary by setting `pulp_site_target_distribution_version` via an extravar.

Alternatively, this sync can be performed automatically during an image build.
To enable this, add `builder` to the `pulp` group in e.g.
`environments/$ENV/inventory/groups` (note the `pulp` group just dictates which
host starts the sync, not which host is running the Pulp server). In this case
`pulp_site_target_distribution_version` is automatically determined from the
builder VM's OS distribution.

In either case you must authenticate with Ark by overriding
`pulp_site_upstream_username` and `pulp_site_upstream_password` with your vault
encrypted Ark dev credentials, and `dnf_repos_username` and `dnf_repos_password`
must remain unset.
