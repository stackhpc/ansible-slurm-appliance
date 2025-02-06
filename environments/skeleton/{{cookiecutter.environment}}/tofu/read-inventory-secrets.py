#!/usr/bin/env python
""" opentofu external data program to load inventory string variables from
    a (possibly vault-encrypted) secrets file.

    Example usage:

        data "external" "example" {
            program = [this_file]

            query = {
                path = "${path.module}/../inventory/group_vars/all/secrets.yml"
            }
        }

    The external data resource's result attribute then contains a mapping of
    variable names to values.

    NB: Only keys/values where values are strings are returned, in line with
    the external program protocol.

    NB: This approach is better than e.g. templating inventory vars as the
    inventory doesn't need to be valid, which is helpful when opentofu will
    template out hosts/groups.
"""

import sys, json, subprocess, yaml
input = sys.stdin.read()
secrets_path = json.loads(input)['path']

with open(secrets_path) as f:
    header = f.readline()
    if header.startswith('$ANSIBLE_VAULT'):
        cmd = ['ansible-vault', 'view', secrets_path]
        ansible = subprocess.run(cmd, capture_output=True, text=True)
        contents = ansible.stdout
    else:
        contents = f.read()

data = yaml.safe_load(contents)

output = {}
for k, v in data.items():
    if isinstance(v, str):
        output[k] = v
print(json.dumps(output))
