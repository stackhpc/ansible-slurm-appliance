#!/usr/bin/python
# pylint: disable=missing-module-docstring

# Copyright: (c) 2021, Steve Brasier <steveb@stackhpc.com>
# Apache V2 licence
from __future__ import absolute_import, division, print_function

from ansible.module_utils.basic import AnsibleModule  # pylint: disable=import-error

__metaclass__ = type  # pylint: disable=invalid-name

DOCUMENTATION = r"""
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
"""

EXAMPLES = r"""
- terminate_user_sessions:
    name: fred
"""

RETURN = r"""
"""


def run_module():  # pylint: disable=missing-function-docstring
    # define available arguments/parameters a user can pass to the module]
    module_args = {
        "user": {
            "type": "str",
            "required": True,
        }
    }

    result = {
        "changed": False,
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    if module.check_mode:
        module.exit_json(**result)

    _, sessions_stdout, _ = module.run_command(
        "loginctl --no-legend list-sessions", check_rc=True
    )
    for line in sessions_stdout.splitlines():
        session_info = line.split()
        user = session_info[1]
        session_id = session_info[0]
        if user == module.params["user"]:
            _, sessions_stdout, _ = module.run_command(
                # pylint: disable-next=consider-using-f-string
                "loginctl terminate-session %s" % session_id,
                check_rc=True,
            )
            result["changed"] = True

    # successful module exit:
    module.exit_json(**result)


def main():  # pylint: disable=missing-function-docstring
    run_module()


if __name__ == "__main__":
    main()
