dnf_repos
=========

Modifies repo definitions for repofiles in `/etc/yum.repos.d` to point to snapshots in StackHPC's Ark Pulp server or mirrors of them
on a local Pulp server.

Requirements
------------

Requires Ark credentials if using StackHPC's upstream Ark server.

Role Variables
--------------

Variables in this role are also required by `pulp_site` so set in 
`environments/common/inventory/groups_vars/all/dnf_repos.yml`. See that file for detailed default values.

- `dnf_repos_repos`: Dict of dicts containing information to construct URLs for Ark snapshots from the target Pulp server for each Rocky version. For example:
    ```
    dnf_repos_repos:
        appstream:                          # ansible.builtin.yum_repository:name
            '8.10':                           # ansible_distribution_version or ansible_distribution_major_version
                repo_file: Rocky-AppStream      # yum_repository: file
                # repo_name:                    # optional, override yum_repository:name
                pulp_path: rocky/8.10/AppStream/x86_64/os # The subpath of the the upstream Ark server's content endpoint URL for the repo's snapshots, see https://ark.stackhpc.com/pulp/content/
                pulp_timestamp: 20250614T013846
                # pulp_content_url:             # optional, dnf_repos_pulp_content_url
            '9.6':
                ...
    ```
- `dnf_repos_default`: Appliance default repos to use Ark snapshots for. Following same format as `dnf_repos_repos`.
  See for appliance default repo list `environments/common/inventory/group_vars/all/dnf_repo_timestamps.yml`.
- `dnf_repos_extra`: Additional repos to use Ark snapshots for. Follows same format as
  `dnf_repos_repos`. Defaults to `{}`
- `dnf_repos_pulp_content_url`: Optional str. Content URL of Pulp server to use Ark snapshots from. 
  Defaults to `{{ appliances_pulp_url }}/pulp/content`
- `dnf_repos_username`: Optional str. Username for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
- `dnf_repos_password`: Optional str. Password for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
