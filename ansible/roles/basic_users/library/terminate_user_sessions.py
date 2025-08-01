#!/usr/bin/python

# Copyright: (c) 2021, Steve Brasier <steveb@stackhpc.com>
# Apache V2 licence
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: terminate_user_sessions

short_description: Terminate systemd user sessions

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: Terminate systemd user sessions.

options:
    user:
        description: Name of user
        required: true
        type: str
    
author:
    - Steve Brasier (stackhpc.com)
'''

EXAMPLES = r'''
- terminate_user_sessions:
    name: fred
'''

RETURN = r'''
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        user=dict(type='str', required=True),
    )

    result = dict(changed=False)

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    _, sessions_stdout, _ = module.run_command("loginctl --no-legend list-sessions", check_rc=True)
    for line in sessions_stdout.splitlines():
        session_info = line.split()
        user = session_info[1]
        session_id = session_info[0]
        if user == module.params['user']:
            _, sessions_stdout, _ = module.run_command("loginctl terminate-session %s" % session_id, check_rc=True)
            result['changed'] = True
        
    # successful module exit:
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()