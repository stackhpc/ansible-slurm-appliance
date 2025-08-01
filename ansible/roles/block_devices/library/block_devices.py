#!/usr/bin/python

# Copyright: (c) 2021, StackHPC
# Apache 2 License

DOCUMENTATION = r'''
---
module: block_devices

short_description: Return block device paths by serial number.

options: (none)

author:
    - Steve Brasier (@sjpb)
'''

RETURN = r'''
devices:
    description: dict with device serial numbers as keys and full paths (e.g. /dev/sdb) as values
    type: dict
    return: always
'''

import json

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict()
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    _, stdout, _ = module.run_command("lsblk --paths --json -O", check_rc=True)
    
    device_info = json.loads(stdout)['blockdevices']
    result['devices'] = dict((item['serial'], item['name']) for item in device_info)
    module.exit_json(**result)

def main():
    run_module()


if __name__ == '__main__':
    main()
