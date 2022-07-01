#!/usr/bin/python
# -*- coding: utf-8 -*-

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
module: hpl_pq
short_description: Calculate P and Q values for HPL.
version_added: "0.0"
description:
    - "Takes number of processes and returns a dict with keys 'P' and 'Q' giving appropriate values, i.e. with Q equal or slightly larger than P and P * Q == num_processes."
options:
    num_processes:
        description:
            - Number of processes
        required: true
        type: int
requirements:
    - "python >= 3.6"
author:
    - Steve Brasier, StackHPC
"""

EXAMPLES = """
TODO
"""

def factors(n):
    """ Return a sequence of (a, b) tuples where a < b giving factors of n.
        
        Based on https://stackoverflow.com/a/6909532/916373
    """
    return [(i, n//i)  for i in range(1, int(n**0.5) + 1) if n % i == 0]

def run_module():
    module_args = dict(
        num_processes=dict(type="int", required=True),
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    if module.check_mode:
        module.exit_json(**result)
    
    num_processes = module.params["num_processes"]
    f = factors(num_processes)
    p, q = f[-1] # nearest to square

    result['grid'] = {'P':p, 'Q': q}
    module.exit_json(**result)


def main():
    run_module()

if __name__ == "__main__":
    main()
