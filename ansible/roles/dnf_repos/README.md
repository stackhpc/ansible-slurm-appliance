# dnf_repos

Defines GPG keys and DNF repofiles to use specific snapshots from StackHPC's
Ark Pulp server, or a local Pulp mirror of Ark.

## Requirements

Requires Ark credentials if using StackHPC's upstream Ark server.

## Role Variables

Some variables in this role are also required by `pulp_site` role, so defaults
are empty here and constructed by `environments/common/inventory/groups_vars/all/dnf_repos*`.

- `dnf_repos_repos`: Optional dict of dicts defining DNF repofiles referencing
  a Pulp server by repository snapshot timestamp. Structure is e.g.:

  ```yaml
  dnf_repos_repos:
    appstream:
      '8.10':
        repo_file: Rocky-AppStream
        # repo_name:
        pulp_path: rocky/8.10/AppStream/x86_64/os
        pulp_timestamp: 20250614T013846
        # pulp_content_url:
        # gpgcheck:
      ...
  ```

  where:
  - "appstream": String, repository name (`name` parameter for `ansible.builtin.yum_repository`).
  - "8.10": String, `ansible_distribution_version` or `ansible_distribution_major_version`
  - `repo_file`: Required string giving repofile basename (`file` parameter for `ansible.builtin.yum_repository`).
    E.g. `Rocky-AppStream` produces `/etc/yum.repos.d/Rocky-AppStream.repo`.
  - `repo_name`: Optional string, can be used to override the top-level key
    for repository name (useful when repository name is different between
    OS distribution versions).
  - `pulp_path`: Required string, subpath from `dnf_repos_pulp_content_url` to
    snapshot URL. **NB:** This must NOT have a trailing `/`.
  - `pulp_timestamp`: Required string, snapshot timestamp.
  - `pulp_content_url`: Optional string, override `dnf_repos_pulp_content_url`.
  - `gpgcheck`: Optional bool, whether to check GPG signature (same as
    `ansible.builtin.yum_repository`). Default `true`.

  Note the playbook `ansible/ci/update_timestamps.yml` will update the timestamps
  defined in `environments/common/inventory/group_vars/all/dnf_repo_timestamps.yml`
  to the latest available.

- `dnf_repos_pulp_content_url`: Optional str. Default content URL of Pulp server.
  Defaults to `{{ appliances_pulp_url }}/pulp/content``
- `dnf_repos_username`: Optional str. Username for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
- `dnf_repos_password`: Optional str. Password for Ark. Should be set if using upstream StackHPC Ark
  Pulp server, but omitted if using local Pulp server (see `ansible/roles/pulp_site`)
- `dnf_repos_gpg_keys`: Optional dict of dicts defining GPG keys to import to allow
  installation from repositories configured by this role. Structure is e.g.:
  ```yaml
  epel:
    "8":
      path: /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
      key: | # from epel-release
        ...
  ```
  where:
  - "epel": String with arbitrary name - matching the equivalent
    `dnf_repos_repos` entry is recommended.
  - "8": String giving relevant `ansible_distribution_major_version`.
  - `path`: Required string, path on disk for key. Using the path provisioned by a
    release repository or install instructions is recommended.
  - `key:`: Optional string, public key. If this is not given then `path` must
    already exist (e.g. for `rocky` key which is present in GenericCloud
    images but not imported by default).
