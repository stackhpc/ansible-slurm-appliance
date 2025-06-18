# sudoers

Manage sudoers configuration by creating files in `/etc/sudoers.d/`.

## Role Variables

  - `sudoers_groups`: Required list. A list of dictionaries defining sudo group configurations. Each dictionary should contain:
  - `group`: Required string. The group name to grant sudo privileges to.
  - `commands`: Required string. The sudo commands specification (e.g., "ALL=(ALL) ALL").
  - `state`: Optional string. Either "present" (default) or "absent" to remove the configuration.

## Features

  - Creates individual sudoers files for each group in `/etc/sudoers.d/`
  - Validates sudoers syntax using `visudo -cf` before applying
  - Sanitizes group names by replacing spaces and slashes with underscores for filename safety
  - Supports removing sudoers configurations by setting `state: absent`
  - Sets proper permissions (0440) and ownership (root:root) on sudoers files

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  become: yes
  roles:
    - role: sudoers
      vars:
        sudoers_groups:
          - group: SITE_Admins
            commands: "ALL=(ALL) ALL"
          - group: SITE_Users
            commands: "ALL=(ALL) ALL"
          - group: developers
            commands: "ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp"
          - group: old_group
            state: absent
```

## Example Variables

```yaml
# Merge your existing groups like this:
sudoers_groups: "{{ sudo_groups + management_sudo_groups }}"

# Where you have:
sudo_groups:
  - group: SITE_Users
    commands: "ALL=(ALL) ALL"

management_sudo_groups:
  - group: SITE_Admins
    commands: "ALL=(ALL) ALL"
```

## License

Apache v2

## Author Information

StackHPC Ltd.
