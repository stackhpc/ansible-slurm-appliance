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
module: slurm_node_info
short_description: Get information about Slurm nodes
version_added: "0.0"
description:
    - "Gets all the available information from Slurm's `sinfo` command about specified nodes. The returned `info` property is a dict with keys from sinfo --All parameters and values a list of strings in specified node order."
options
    nodes:
        description:
            - Slurm nodenames for which information is required.
        required: true
        type: list
    partition:
        description:
            - Slurm partition to query, if there is more than one.
        required: false
        type: str
requirements:
    - "python >= 3.6"
author:
    - Steve Brasier, StackHPC
"""

EXAMPLES = """
TODO
"""


def run_module():
    module_args = dict(
        nodes=dict(type="list", required=True),
        partition=dict(type="str", required=False),
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    if module.check_mode:
        module.exit_json(**result)
    
    node_spec = ','.join(module.params['nodes'])
    partition_arg = '--partition=%s' % module.params['partition'] if module.params['partition'] else ''
    _, stdout,_ = module.run_command("sinfo --Format All --nodes=%s %s" % (node_spec, partition_arg), check_rc=True)
    lines = stdout.splitlines()
    if len(lines) > (len(module.params['nodes']) + 1): # +1 for header
        raise ValueError('Got %i lines of output for %i nodes - mismatch. Did you specify partition?' % (len(lines), len(module.params['nodes'])))
    info = {}
    params = [v.strip() for v in lines[0].split('|')]
    values = [line.split('|') for line in lines[1:]]
    for ix, param in enumerate(params):
        info[param] = [nodeinfo[ix].strip() for nodeinfo in values]
    result['info'] = info
    
    module.exit_json(**result)


def main():
    run_module()

if __name__ == "__main__":
    main()
