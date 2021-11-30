#!/usr/bin/python

# Copyright: (c) 2021, StackHPC
# Apache 2 License

DOCUMENTATION = r'''
---
module: block_device_info

short_description: Return information about block devices using `lsblk` command.

options:
    key:
        description: lsblk "output column" to use as dict key - see Return values
        required: false
        type: str

author:
    - Steve Brasier (@sjpb)
'''

RETURN = r'''
device_list:
    description: json-format list of device info as returned by lsblk.
    type: list
    return: always
device_dict:
    description: dict of device info, keyed by `key`
    type: dict
'''

import json

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        key=dict(type="str", required=False),
        )
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    _, stdout, _ = module.run_command("lsblk  --json -O", check_rc=True)
    
    device_info = json.loads(stdout)['blockdevices']
    
    result['device_list'] = device_info
    key = module.params['key']
    if key is not None:
        result['device_dict'] = dict((item[key], item) for item in device_info)
    module.exit_json(**result)

def main():
    run_module()


if __name__ == '__main__':
    main()