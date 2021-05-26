#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.slurm_utils import slurm_parse

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

def run_module():
    module_args = dict(
        name=dict(type="str", required=True),
        state=dict(type="str", required=True, choices=['absent', 'present']),
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}

    cluster = module.params["name"]
    state = module.params["state"]

    if module.check_mode:
        module.exit_json(**result)

    _,stdout,_ = module.run_command("sacctmgr list cluster -p", check_rc=True)
    records = slurm_parse(stdout)
    clusters = [record["Cluster"] for record in records]

    if (cluster not in clusters and state == "present") or (cluster in clusters and state == "absent"):
        result["changed"] = True

    if module.check_mode or not result["changed"]:
        module.exit_json(**result)

    if state == "present":
        module.run_command("sacctmgr --immediate add cluster name=%s" % cluster, check_rc=True)
    else:
        module.run_command("sacctmgr --immediate delete cluster name=%s" % cluster, check_rc=True)

    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
