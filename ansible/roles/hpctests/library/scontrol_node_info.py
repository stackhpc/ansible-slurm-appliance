#!/usr/bin/python
# pylint: disable=missing-module-docstring
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, StackHPC
# Apache 2 License
import json
import re

from ansible.module_utils.basic import AnsibleModule  # pylint: disable=import-error

ANSIBLE_METADATA = {
    "metadata_version": "0.1",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: scontrol_node_info
short_description: Get information about Slurm nodes via scontrol
version_added: "0.0"
description: >
    Gets all the available information from Slurm's `scontrol show nodes` command about specified nodes.
    The returned `info` property is a dict with keys from scontrol --
    All parameters and values a list of strings in specified node order.
options
    nodes:
        description:
            - Slurm nodenames for which information is required.
        required: true
        type: list
requirements:
    - "python >= 3.6"
author:
    - Eric Le Lay, StackHPC
"""

EXAMPLES = """
TODO
"""


def run_module():  # pylint: disable=missing-function-docstring
    module_args = {
        "nodes": {
            "type": "list",
            "required": True,
        }
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    if module.check_mode:
        module.exit_json(**result)

    _, stdout, _ = module.run_command(
        ["scontrol", "show", "nodes", "--json", ",".join(module.params["nodes"])],
        check_rc=True,
    )  # `--nodes` doesn't filter enough, other partitions are still shown
    info = json.loads(stdout)
    for node_info in info.get("nodes", []):
        node_info["gpus"] = {}
        if "gres" in node_info:
            gres = node_info["gres"]
            for g in gres.split(","):
                m = re.match(r"""^gpu:(.+):([0-9]+)\(S:[0-9]+\)$""", g)
                if m:
                    resource, cnt = m.group(1), m.group(2)
                    node_info["gpus"][resource] = int(cnt)
    result["info"] = info.get("nodes", [])
    module.exit_json(**result)


def main():  # pylint: disable=missing-function-docstring
    run_module()


if __name__ == "__main__":
    main()
