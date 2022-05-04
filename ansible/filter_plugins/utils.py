#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.errors import AnsibleError, AnsibleFilterError
from ansible.utils.display import Display
from collections import defaultdict
import jinja2
from ansible.module_utils.six import string_types
import os.path

def prometheus_node_exporter_targets(hosts, env):
    result = []
    per_env = defaultdict(list)
    for host in hosts:
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

    def warn(self, message, **kwargs):
        Display().warning(message)
        return message

    def filters(self):
        return {
            # jinja2 overrides
            'readfile': readfile,
            'prometheus_node_exporter_targets': prometheus_node_exporter_targets,
            'exists': exists,
            'warn': self.warn
        }
