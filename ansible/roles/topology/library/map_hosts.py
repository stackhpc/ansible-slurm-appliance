#!/usr/bin/python

# Copyright: (c) 2025, StackHPC
# Apache 2 License

from ansible.module_utils.basic import AnsibleModule
import openstack

DOCUMENTATION = """
---
module: map_hosts
short_description: Creates map of OpenStack VM network topology
description:
    - Creates map representing the network topology tree of an OpenStack project with a heirarchy
      of: Availability Zone -> Hypervisors -> VMs/Baremetal instances
options:
    compute_vms:
        description:
            - List of VM names within the target OpenStack project to include in the tree
        required: true
        type: str
author:
    - Steve Brasier, William Tripp, StackHPC
"""

RETURN = """
topology:
    description:
      Map representing tree of project topology. Top level keys are AZ names, their values
      are maps of shortened unique identifiers of hosts UUIDs to lists of VM names
    returned: success
    type: dict[str, dict[str,list[str]]]
    sample:
      "nova-az":
        "afe9":
          - "mycluster-compute-0"
          - "mycluster-compute-1"
        "00f9":
          - "mycluster-compute-vm-on-other-hypervisor"
"""

EXAMPLES = """
- name: Get topology map
  map_hosts:
    compute_vms:
      - mycluster-compute-0
      - mycluster-compute-1
"""

def min_prefix(uuids, start=4):
    """ Take a list of uuids and return the smallest length >= start which keeps them unique """
    for length in range(start, len(uuids[0])):
        prefixes = set(uuid[:length] for uuid in uuids)
        if len(prefixes) == len(uuids):
            return length

def run_module():
    module_args = dict(
        compute_vms=dict(type='list', elements='str', required=True)
    )
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    conn = openstack.connection.from_config()

    servers = [s for s in conn.compute.servers() if s["name"] in module.params["compute_vms"]]

    topo = {}
    all_host_ids = []
    for s in servers:
        az = s['availability_zone']
        host_id = s['host_id']
        if host_id != '':
            all_host_ids.append(host_id)
            if az not in topo:
                topo[az] = {}
            if host_id not in topo[az]:
                topo[az][host_id] = []
            topo[az][host_id].append(s['name'])

    uuid_len = min_prefix(list(set(all_host_ids)))

    for az in topo:
        topo[az] = dict((k[:uuid_len], v) for (k, v) in topo[az].items())

    result = {
        "changed": True, 
        "topology": topo,
    }
    
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
