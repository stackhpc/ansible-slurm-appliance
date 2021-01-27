#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.errors import AnsibleError, AnsibleFilterError
from collections import defaultdict
import jinja2
from ansible.module_utils.six import string_types
import os.path

def _get_hostvar(context, var_name, inventory_hostname=None):
    if inventory_hostname is None:
        namespace = context
    else:
        if inventory_hostname not in context['hostvars']:
            raise AnsibleFilterError(
                "Inventory hostname '%s' not in hostvars" % inventory_hostname)
        namespace = context["hostvars"][inventory_hostname]
    return namespace.get(var_name)

@jinja2.contextfilter
def prometheus_node_exporter_targets(context, hosts):
    result = []
    per_env = defaultdict(list)
    for host in hosts:
        env = _get_hostvar(context, "env", host) or "ungrouped"
        per_env[env].append(host)
    for env, hosts in per_env.items():
        target = {
            "targets": ["{target}:9100".format(target=target) for target in hosts],
            "labels": {
                "env": env
            }
        }
        result.append(target)
    return result

def readfile(fpath):
    if not os.path.isfile(fpath):
        return ""
    with open(fpath) as f:
        return f.read()

def exists(fpath):
    return os.path.isfile(fpath)

class FilterModule(object):
    ''' Ansible core jinja2 filters '''

    def filters(self):
        return {
            # jinja2 overrides
            'readfile': readfile,
            'prometheus_node_exporter_targets': prometheus_node_exporter_targets,
            'exists': exists
        }