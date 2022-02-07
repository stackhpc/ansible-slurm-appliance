#!/usr/bin/env python3
"""
Make HPC Datasets
Usage: cluster_dataset_manager.py --list

Note: Ansible-Vault encrypted YAML file with LEX API
"""
import json
import os
import requests
import time
import yaml
from subprocess import Popen, PIPE
from optparse import OptionParser
import socket


HOST_SYSTEMS = { "Gyrfalcon": "gyrfalcon-mds.hpc.nrel.gov", "Eagle": "esac", "vermilion": "vs-admin", "vstack": "vstack-admin"}
SYSTEMS_LIST = (("Gyrfalcon", False), ("Eagle", False), ("vermilion", True), ("vtest", True))

def read_ansible_config(vault_file="{{cluster_dataset_manager_install_path}}/{{cluster_dataset_manager_vault_file}}", secret_file="{{cluster_dataset_manager_install_path}}/{{cluster_dataset_manager_vault_secret_file}}"):
    CONFIGS = {}
    p = Popen(["ansible-vault", "view", "--vault-password-file=%s" % secret_file, vault_file], stdout=PIPE)
    stream = p.communicate()[0]
    if not p.returncode == 0:
       raise Exception("Failed to open ansible vault file %s using secret file %s" % (vault_file, secret_file))
    CONFIGS = yaml.load(stream)
    return CONFIGS

def get_lex_data(system):
    if os.path.isfile(os.path.join('/etc/ssl/certs/','wildcard.hpc.nrel.gov.bundle.crt')):
        os.environ['REQUESTS_CA_BUNDLE'] = os.path.join('/etc/ssl/certs/','wildcard.hpc.nrel.gov.bundle.crt')
    CONFIGS = read_ansible_config()

    r = requests.get('https://lex.hpc.nrel.gov/api/projects/allocatedstorage/?system=%s' % system, auth=(CONFIGS['USERNAME'], CONFIGS['PASSWD']), verify=True, timeout=60)
    if r.status_code == requests.codes.ok:
        json_data = r.json()
        return(json_data)
    else:
        raise Exception("Failed to get lex data")

def get_systems():
    """
    Get List of HPC Systems
    """
    return SYSTEMS_LIST


def get_host_system(system):
    """
    Get host system for a particular HPC system, the host system is the server that you apply the configuration to.
    """
    host_system_lookup = HOST_SYSTEMS
    if system in host_system_lookup:
        return host_system_lookup[system]
    else:
        raise Exception("Host System lookup for system %s failed" % system)

def get_host_cluster():
    """
    Get cluster from a specific hostname
    """
    host_system_lookup = HOST_SYSTEMS
    my_hostname = socket.gethostname()
    for system in host_system_lookup:
        if host_system_lookup[system] == my_hostname:
            return system

    raise Exception("Cluster System lookup for system %s and my_hostname %s failed" % (system, my_hostname))

def get_datasets(system, enforce_lowercase_dir=False):
    """
    Return list of the datasets. Example: [{"path": "/user1", "group": "abcdef", "owner": "user1", "mode": "755"}]
    """
    # allow vtest to use the vermilion data until Lex is able to
    # set up additional projects.
    if system == "vtest":
        system = "vermilion"

    datasets = []
    lex_data = get_lex_data(system)

    for allocation in lex_data:
        cr_system=allocation["system"]
        cr_mountpoint=allocation["mount_point"]
        cr_group=allocation["idm_group"]
        cr_pi=allocation["project"]["hpc_lead_person"]
        cr_permission=allocation["permissions"]

        # Set dir lowercase
        if enforce_lowercase_dir:
            cr_mountpoint = cr_mountpoint.lower()

        # If no PI then set owner to root
        if not cr_pi:
            cr_pi = "root"

        # If no mode/permission is set, make it default
        if cr_permission is None:
            cr_permission = "2770"

        datasets.append({"path": cr_mountpoint, "group": cr_group, "owner": cr_pi, "mode": cr_permission})

    # Test Data below, will query the allocation databas later to collect this data
    return datasets


def main():
    """
    Main Entry
    """
    hostgroups = {}

    parser = OptionParser()
    parser.add_option("-l", "--list", dest="list", action="store_false")
    parser.add_option("-s", "--host", dest="host", action="store_false")
    (options, args) = parser.parse_args()
    if (options.host is not None):
        Exception("Currently do not support the --host option, only --list")
        exit(0)
    if (options.list is None):
        parser.print_help()
        exit(0)


    for (system, enforce_lowercase_dir) in get_systems():
        hostgroups[system] = {"hosts": [get_host_system(system)], "vars": {"datasets_mountpoints": get_datasets(system, enforce_lowercase_dir=enforce_lowercase_dir)}}

    print(json.dumps(hostgroups))


if __name__ == "__main__":
    """
    Example JSON out
    {"group_inventorylist_name": {"hosts": ["host1","host2"], "vars": {"datasets_mountpoints": [{"path": "/user1","group": "abcdef", "owner": "user1", "mode": "755"}]}]}}
    """
    main()
