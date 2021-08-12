#!/usr/bin/env python

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
module: read_imb_pingpong
short_description: Read output files from Intel MPI Benchmarks IMB-MPI1 pingpong
version_added: "0.0"
description:
    - "Read output files from Intel MPI Benchmarks IMB-MPI1 pingpong"
options:
    path:
        description:
            - Path to output file
        required: true
        type: str
requirements:
    - "python >= 3.6"
author:
    - Steve Brasier, StackHPC
"""

EXAMPLES = """
- name: Read pingpong
  read_imb_pingpong:
    path: /mnt/nfs/examples/pingpong.out
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