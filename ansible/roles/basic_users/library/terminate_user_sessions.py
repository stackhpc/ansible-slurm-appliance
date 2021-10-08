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

<<<<<<< HEAD
description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
=======
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
>>>>>>> main
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
        try:
            session, uid, user = line.split()
        except ValueError:
            raise ValueError('failed to split "%s"' % line)
            
        if user == module.params['user']:
            _, sessions_stdout, _ = module.run_command("loginctl terminate-session %s" % session, check_rc=True)
            result['changed'] = True
        
    # successful module exit:
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()