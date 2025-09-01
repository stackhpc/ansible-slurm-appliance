pulp_site
=========

Contains playbooks to deploy a Pulp server and sync its content with repo snapshots in
StackHPC's Ark Pulp server

Requirements
------------

Requires Ark credentials. The VM you are deploying Pulp on must allow ingress on `pulp_site_port`
and not be externally accessible (as the Pulp server's content is unauthenticated). Rocky Linux 9 has been
tested as the target VM for deploying Pulp.

Role Variables
--------------

- `pulp_site_url`: Required str. The base url from which Pulp content will be hosted. Defaults to `{{ appliances_pulp_url }}`. 
                 Value to set for ``appliances_pulp_url` will be generated and output by the deploy.yml playbook.
- `pulp_site_port`: Optional str. Port to serve Pulp server on. Defaults to `8080`.
- `pulp_site_username`: Optional str. Admin username for the Pulp server. Defaults to `admin`.
- `pulp_site_password`: Required str. Admin password for the Pulp server. Defaults to `{{ vault_pulp_admin_password }}`.
- `pulp_site_upstream_username`: Required str. Username for accessing content from the upstream Ark Pulp server.
- `pulp_site_upstream_password`: Required str. Password for upstream Ark Pulp server.
- `pulp_site_upstream_content_url`: Optional str. Content URL of upstream Ark Pulp. Defaults to `https://ark.stackhpc.com/pulp/content`.
- `pulp_site_install_dir`: Optional str. Directory on Pulp host to install config and persistent state to be mounted into Pulp container. Defaults to `/home/rocky/pulp`.
- `pulp_site_target_facts`: Optional str. The `ansible_facts` of a host which will be pulling from your Pulp server, allowing the role to auto-discover the necessary repos to pull.
                          defaults to `{{ hostvars[groups['pulp'][0]]['ansible_facts'] }}`.
- `pulp_site_target_distribution_version`: Optional str. The Rocky Linux minor release to sync repos from Ark for. Defaults to `{{ pulp_site_target_facts['distribution_version'] }}`.
- `pulp_site_rpm_repo_defaults`: Optional dict. Contains key value pairs for fields which are common to all repo definition in `pulp_site_rpm_repos`. Includes values for `remote_username`,
                               `remote_password` and `policy` by default.
- `pulp_site_rpm_repos`: Optional list of dicts. List of repo definitions in format required by the `stackhpc.pulp.pulp_repository`. Defaults to modified versions of repos defined in
                       `dnf_repos_all`.
- `pulp_site_rpm_publications`: Optional list of dicts. List of repo definitions in format required by the `stackhpc.pulp.pulp_publication`. Defaults to list of publications for repos defined in
                              `dnf_repos_all`.
- `pulp_site_rpm_distributions`: Optional list of dicts. List of repo definitions in format required by the `stackhpc.pulp.pulp_distribution`. Defaults to list of distributions for repos defined in
                              `dnf_repos_all`.
