#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.errors import AnsibleError, AnsibleFilterError
from ansible.utils.display import Display
from collections import defaultdict
import jinja2
from ansible.module_utils.six import string_types
import os.path
import re

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

def to_ood_regex(items):
    """ Convert a list of strings possibly containing digits into a regex containing \d+
    
        eg {{ [compute-001, compute-002, control] | to_regex }} -> '(compute-\d+)|(control)'
    """
    
    # There's a python bug which means re.sub() can't use '\d' in the replacement so
    # have to do replacement in two stages:
    r = [re.sub(r"\d+", 'XBACKSLASHX', v) for v in items]
    r = [v.replace('XBACKSLASHX', '\d+') for v in set(r)]
    r = ['(%s)' % v for v in r]
    return '|'.join(r)

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
            'warn': self.warn,
            'to_ood_regex': to_ood_regex,
        }
