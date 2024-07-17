#!/usr/bin/env python
""" Convert /etc/passwd and /etc/group files into yaml for Ansible

    Usage:
        parse_user_data.py grid-passwd grid-group

    Outputs:
        ansible-groups.yml: For use with ansible.builtin.group
        ansible-users.yml: For use with ansible.builtin.user
"""

import sys, yaml

def parse_passwd(passwd_file):
    users = []
    with open(passwd_file, 'r') as f:
        for line in f:
            if line.strip():
                parts = line.strip().split(':')
                if len(parts) == 7:
                    user = {
                        'name': parts[0],
                        'uid': int(parts[2]),
                        'gid': int(parts[3]),
                        'comment': parts[4] if parts[4] else None,
                        'home': parts[5],
                        'shell': parts[6]
                    }
                    users.append(user)
                else:
                    raise ValueError(f'line in {passwd_file} did not have 7 parts: {line}')
    return users

def parse_groups(group_file):
    groups = []
    with open(group_file, 'r') as f:
        for line in f:
            if line.strip():
                parts = line.strip().split(':')
                if len(parts) == 4:
                    group = {
                        'name': parts[0],
                        'gid': int(parts[2]),
                        'members': parts[3].split(',') if parts[3] else []
                    }
                    groups.append(group)
                else:
                    raise ValueError(f'line in {group_file} did not have 4 parts: {line}')
    return groups

def main(passwd_file, group_file):
    users = parse_passwd(passwd_file)
    groups = parse_groups(group_file)

    # Map GID to group name for easy lookup
    gid_to_group = {group['gid']: group['name'] for group in groups}
    
    # Map username to secondary groups
    username_to_groups = {user['name']: [] for user in users}

    for group in groups:
        for member in group['members']:
            if member in username_to_groups and group['gid'] != username_to_groups[member]:
                username_to_groups[member].append(group['name'])

    ansible_groups = [{'gid': group['gid'], 'name': group['name']} for group in groups]

    ansible_users = []
    for user in users:
        primary_group_name = gid_to_group.get(user['gid'], '')

        # Exclude the primary group from the supplementary groups list
        supplementary_groups = [group_name for group_name in username_to_groups[user['name']] if group_name != primary_group_name]

        ansible_user = {
            'name': user['name'],
            'uid': user['uid'],
            'group': primary_group_name,
            'home': user['home'],
            'shell': user['shell']
        }
        if user['comment']:
            ansible_user['comment'] = user['comment']

        if supplementary_groups:
            ansible_user['groups'] = supplementary_groups

        ansible_users.append(ansible_user)

    with open('ansible-groups.yml', 'w') as f:
        yaml.dump(ansible_groups, f, default_flow_style=False)

    with open('ansible-users.yml', 'w') as f:
        yaml.dump(ansible_users, f, default_flow_style=False)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Invalid arguments.\n' + __doc__.split('\n\n')[1])
        sys.exit(1)
    passwd_file = sys.argv[1]
    group_file = sys.argv[2]
    main(passwd_file, group_file)
