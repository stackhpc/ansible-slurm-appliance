#!/usr/bin/env python
""" opentofu external data program to list baremetal nodes

    Example usage:

        data "external" "example" {
            program = [this_file]
        }

    The external data resource's result attribute then contains a mapping of
    Ironic node names to their UUIDs.

    An empty list is returned if:
    - There are no baremetal nodes
    - The listing fails for any reason, e.g.
        - there is no baremetal service
        - admin credentials are required and are not provided
"""

import openstack
import json

nodes = []
proxy = None
output = {}
conn = openstack.connection.from_config()
try:
    proxy = getattr(conn, 'baremetal', None)
except Exception:
    pass
if proxy is not None:
    nodes = proxy.nodes()
for node in nodes:
    output[node.name] = node.id
print(json.dumps(output))
