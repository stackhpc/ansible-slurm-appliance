#!/usr/bin/python

# Copyright: (c) 2020, Will Szumski <will@stackhpc.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: user_namepace_facts

short_description: Returns subgid and subuid maps

version_added: "1.0.0"

description: Returns subgid and subuid maps.

author:
    - Will Szumski (@jovial)
'''

EXAMPLES = r'''
- name: Return ansible_facts
  user_namepace_facts:
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
ansible_facts:
  description: Facts to add to ansible_facts.
  returned: always
  type: dict
  contains:
    subuid:
      description: Parsed output of /etc/subuid
      type: str
      returned: always, empty dict if /etc/subuid doesn't exist
      sample: { "foo": {"size": 123, "start": 100000 }}
    subgid:
      description: Parsed output of /etc/subgid
      type: str
      returned: always, empty dict if /etc/subgid doesn't exist
      sample: { "foo": {"size": 123, "start": 100000 }}
'''

from ansible.module_utils.basic import AnsibleModule
import csv
import os

def parse(path):
    result = {}

    if not os.path.exists(path):
        return result

    with open(path) as f:
        reader = csv.reader(f, delimiter=':')
        for row in reader:
            user = row[0]
            entry = {
                "start": int(row[1]),
                "size": int(row[2]),
            }
            result[user] = entry

    return result

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict()

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        ansible_facts=dict(),
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)

    result = {
        'ansible_facts': {
            'subuid': {},
            'subgid': {}
        }
    }

    result['ansible_facts']['subuid'] = parse('/etc/subuid')
    result['ansible_facts']['subgid'] = parse('/etc/subgid')

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
