dnf_repos
=========

Modifies repo definitions for repofiles in `/etc/yum.repos.d` to point to snapshots in StackHPC's Ark Pulp server.

Requirements
------------

Requires Ark credentials.

Role Variables
--------------

Variables in this role are also required by `pulp_site` so set in 
`environments/common/inventory/groups_vars/all/dnf_repos.yml`. See that file for detailed default values.

- `dnf_repos_all`: Dict of dicts containing information to construct URLs for timestamped repos from Ark for each Rocky version. For example:
    ```
    dnf_repos_all:
        appstream:                          # ansible.builtin.yum_repository:name
            '8.10':                           # ansible_distribution_version or ansible_distribution_major_version
                repo_file: Rocky-AppStream      # yum_repository: file
                # repo_name:                    # optional, override yum_repository:name
                pulp_path: rocky/8.10/AppStream/x86_64/os
                pulp_timestamp: 20250614T013846
                # pulp_content_url:             # optional, dnf_repos_pulp_content_url
            '9.6':
                ...
    ```
- `dnf_repos_default`: Appliance default repos to use Ark snapshots for. Follows same format as
  `dnf_repos_all`, but includes top level keys to allow repos to be conditionally included in 
  `dnf_repos_all`. See `environments/common/inventory/group_vars/all/dnf_repos.yml` and
  `environments/common/inventory/group_vars/all/timestamps.yml` for full templating logic.
- `dnf_repos_extra`: Additional repos to use Ark snapshots for. Follows same format as
  `dnf_repos_all`. Defaults to `{}`
- `dnf_repos_no_epel`: Dict of all repos included in `dnf_repos_all` excluding 
  `epel`, used to prevent conflicts with repofile installed by `epel-release`
- `dnf_repos_default_epel`: Dict of repos objects following same format as `dnf_repos_all` but only 
   including `epel` repo. 
- `dnf_repos_pulp_content_url`: Optional str. Content URL of Pulp server to use Ark snapshots from. 
  Defaults to `{{ appliances_pulp_url }}/pulp/content`
- `dnf_repos_username`: Optional str. Username for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
- `dnf_repos_password`: Optional str. Password for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
