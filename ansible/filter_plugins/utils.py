#!/usr/bin/python
# pylint: disable=missing-module-docstring

# Copyright: (c) 2020, StackHPC
# Apache 2 License

import os.path
import re
from collections import defaultdict

from ansible.utils.display import Display  # pylint: disable=import-error


def prometheus_node_exporter_targets(hosts, hostvars, env_key, group):
    """Return a mapping in cloudalchemy.nodeexporter prometheus_targets
    format.

    hosts: list of inventory_hostnames
    hostvars: Ansible hostvars variable
    env_key: key to lookup in each host's hostvars to add as label 'env' (default: 'ungrouped')
    group: string to add as label 'group'
    """
    result = []
    per_env = defaultdict(list)
    for host in hosts:
        host_env = hostvars[host].get(env_key, "ungrouped")
        per_env[host_env].append(host)
    for env, hosts in per_env.items():  # pylint: disable=redefined-argument-from-local
        target = {
            "targets": [f"{target}:9100" for target in hosts],
            "labels": {"env": env, "group": group},
        }
        result.append(target)
    return result


def readfile(fpath):  # pylint: disable=missing-function-docstring
    if not os.path.isfile(fpath):
        return ""
    with open(fpath) as f:  # pylint: disable=unspecified-encoding
        return f.read()


def exists(fpath):  # pylint: disable=missing-function-docstring
    return os.path.isfile(fpath)


def to_ood_regex(items):
    """Convert a list of strings possibly containing digits into a regex containing \\d+

    eg {{ [compute-001, compute-002, control] | to_regex }} -> '(compute-\\d+)|(control)'
    """

    # NB: for python3.12+ the \d in this function & docstring
    # need to be raw strings. See
    # https://docs.python.org/3/reference/lexical_analysis.html

    # There's a python bug which means re.sub() can't use '\d' in the replacement so
    # have to do replacement in two stages:
    r = [re.sub(r"\d+", "XBACKSLASHX", v) for v in items]
    r = [v.replace("XBACKSLASHX", r"\d+") for v in set(r)]
    r = [f"({v})" for v in r]
    return "|".join(r)


# pylint: disable=useless-object-inheritance
class FilterModule(object):
    """Ansible core jinja2 filters"""

    # pylint: disable=missing-function-docstring
    def warn(self, message, **kwargs):  # pylint: disable=unused-argument
        Display().warning(message)
        return message

    # pylint: disable=missing-function-docstring
    def filters(self):
        return {
            # jinja2 overrides
            "readfile": readfile,
            "prometheus_node_exporter_targets": prometheus_node_exporter_targets,
            "exists": exists,
            "warn": self.warn,
            "to_ood_regex": to_ood_regex,
        }
