# Pulp Server

In order to ensure reproducibility, by default image builds use mirrors of DNF
repositories hosted on StackHPC's "Ark" Pulp server. This page describes how to
use a local Pulp server instead of Ark, which reduces network traffic and speeds
up builds. The repositories on this local Pulp server are synchronised to Ark so
that builds still use the same package snapshots.

It is also possible to use a local Pulp server to install packages during the
`site.yml` playbook rather than during image builds, as described in [docs/operations.md](../operations.md#adding-additional-packages).

## Deploying and Configuring a Local Pulp Server

The appliance can install and configure a local Pulp server on a specified host.
This host should run RockyLinux 8 or 9 and have at least 2 vCPUs and 8GB RAM.
Note upgrades etc. of this host will not be managed by the appliance. Access to
Pulp content is not authenticated so this server should not be externally
reachable.

> [!IMPORTANT]
> Commands below should be run with the `staging` environment active, as all
> Pulp syncs will be done from there.

1.  Define the host in a group `pulp_server` within the `site` inventory. This
    means clusters in all environments use the same Pulp server, and the synced
    DNF repository snapshots are tested in staging before use in production. E.g.:

    ```ini
    # environments/site/inventory/pulp:
    [pulp_server]
    pulp_host ansible_host=<VM-ip-address>
    ```

    > [!WARNING]
    > The inventory hostname cannot conflict with group names, i.e it cannot be
    `pulp_site` or `pulp_server`.

2.  If adding Pulp to an existing deployment, ensure Pulp admin credentials
    exist:

    ```shell
    ansible-vault decrypt ansible/adhoc/generate-passwords.yml
    ansible-playbook ansible/adhoc/generate-passwords.yml
    ansible-vault encrypt ansible/adhoc/generate-passwords.yml
    ```

3.  Run the adhoc playbook to install and configure Pulp:

    ```shell
    ansible-playbook ansible/adhoc/deploy-pulp.yml
    ```

    Once complete, it will print a message giving a value to set for
    `appliances_pulp_url`, assuming the inventory `ansible_host` address is
    also the address the cluster should use to reach the Pulp server.

4.  Create group vars files defining `appliances_pulp_url` and dev credentials
    for StackHPC's "Ark" Pulp server:

    ```yaml
    # environments/site/inventory/group_vars/all/pulp.yml:
    appliances_pulp_url: "http://<pulp-host-ip>:8080"
    pulp_site_upstream_username: your-ark-username
    pulp_site_upstream_password: "{{ vault_pulp_site_upstream_password }}"
    ```

    ```yaml
    # environments/site/inventory/group_vars/all/vault_pulp.yml:
    vault_pulp_site_upstream_password: your-ark-password
    ```

    and vault-encrypt the latter:

    ```shell
    ansible-vault encrypt environments/site/inventory/group_vars/all/vault_pulp.yml
    ```
    
    If previously using Ark credentials directly e.g. for image builds, ensure
    the variables `dnf_repos_username` and `dnf_repos_password` are no longer
    set in any environment.

5.  Commit changes.

## Using an existing Pulp server

Alternatively, an existing Pulp server can be used to host Ark repos by
setting `appliances_pulp_url` directly. Note that this assumes the same
configuration as the appliance deployed Pulp i.e no content authentication.
As above, the `dnf_repos_` variables must not be set in this configuration.

## Syncing Pulp content with Ark

The appliance can synchronise repositories on local Pulp server from Ark in
two ways:

1.  If the `pulp_site` group is added to the Packer build groups, the local Pulp
server will be synced with Ark during image builds.

2. The sync can be manually be triggered by running:

    ```shell
    ansible-playbook ansible/adhoc/sync-pulp.yml
    ```

    By default this method syncs repositories for the latest version of RockyLinux
    supported by the appliance. This can be overridden by setting
    `pulp_site_target_distribution_version` to e.g. `'8.10'`, i.e the `Major.minor`
    version of RockyLinux the site clusters are using. **NB:** This value
    must be quoted to avoid an incorrect conversion to float.
