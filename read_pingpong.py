#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.module_utils.basic import AnsibleModule
import json

ANSIBLE_METADATA = {
    "metadata_version": "0.1",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: sacct_cluster
short_description: Manages clusters in the accounting database
version_added: "2.9"
description:
    - "Adds/removes a cluster from the accounting database"
options:
    name:
        description:
            - Name of the cluster
        required: true
        type: str
    state:
        description:
        - If C(present), cluster will be added if it does't already exist
        - If C(absent), cluster will be removed if it exists
        type: str
        required: true
        choices: [ absent, present]
requirements:
    - "python >= 3.6"
author:
    - Will Szumski, StackHPC
"""

EXAMPLES = """
- name: Create a cluster
  slurm_acct:
    name: test123
    state: present
"""

CONVERTERS = (int, int, float, float)
COLUMNS = ('bytes', 'repetitions', 'latency', 'bandwidth')

def run_module():
    module_args = dict(
        path=dict(type="str", required=True),
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    
    path = module.params["path"]
    if module.check_mode:
        module.exit_json(**result)

    columns = ([], [], [], [])
    with open(path) as f:
        for line in f:
            if line == '       #bytes #repetitions      t[usec]   Mbytes/sec\n':
                while True:
                    line = next(f).strip()
                    if line == '':
                        break
                    for ix, v in enumerate(line.split()):
                        columns[ix].append(CONVERTERS[ix](v))
    
    result['columns'] = {
        'bytes': columns[0],
        'repetitions': columns[1],
        'latency': columns[2],
        'bandwidth': columns[3],
    }
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()