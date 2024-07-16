#!/usr/lib/ansible-init/bin/python

import json
import logging
import os
import pathlib
import subprocess
import yaml

import requests


logging.basicConfig(level = logging.INFO, format = "[%(levelname)s] %(message)s")


logger = logging.getLogger(__name__)


def assemble_list(data, prefix):
    """
    Assembles a list of items based on keys in data with the format "<prefix>_<idx>_<key>".
    """
    list_items = {}
    for key, value in data.items():
        if not key.startswith(prefix):
            continue
        idx, item_key = key.removeprefix(prefix).split("_", maxsplit = 1)
        list_items.setdefault(idx, {})[item_key] = value
    return [list_items[k] for k in sorted(list_items.keys())]


def ansible_exec(cmd, *args, **kwargs):
    """
    Execute an Ansible command with the appropriate environment.
    """
    environ = os.environ.copy()
    environ["ANSIBLE_CONFIG"] = "/etc/ansible-init/ansible.cfg"
    cmd = f"/usr/lib/ansible-init/bin/ansible-{cmd}"
    subprocess.run([cmd, *args], env = environ, check = True, **kwargs)


logger.info("fetching instance metadata")
METADATA_URL = "http://169.254.169.254/openstack/latest/meta_data.json"
response = requests.get(METADATA_URL)
response.raise_for_status()
user_metadata = response.json().get("meta", {})

# here: get user_metadata['ansible-init-metadata'] and write it as yaml? to etc/ansible-init/inventory/whatever.json/.yaml
ansible_metadata_str = user_metadata.get('ansible-init-vars', {})
ansible_metadata = json.loads(ansible_metadata_str)
ansible_filepath = '/etc/ansible-init/inventory/group_vars/all/nfs-metadata.yml'
os.makedirs(os.path.dirname(ansible_filepath), exist_ok=True)
with open(ansible_filepath, 'w') as yaml_file:
    yaml.dump(ansible_metadata, yaml_file, default_flow_style=False)

logger.info("extracting collections and playbooks from metadata")
collections = assemble_list(user_metadata, "ansible_init_coll_")
playbooks = assemble_list(user_metadata, "ansible_init_pb_")
logger.info(f"  found {len(collections)} collections")
logger.info(f"  found {len(playbooks)} playbooks")


logger.info("installing collections")
ansible_exec(
    "galaxy",
    "collection",
    "install",
    "--force",
    "--requirements-file",
    "/dev/stdin",
    input = json.dumps({ "collections": collections }).encode()
)


logger.info("executing remote playbooks for stage - pre")
for playbook in playbooks:
    if playbook.get("stage", "post") == "pre":
        logger.info(f"  executing playbook - {playbook['name']}")
        ansible_exec(
            "playbook",
            "--connection",
            "local",
            "--inventory",
            "127.0.0.1,",
            playbook["name"]
        )


logger.info("executing playbooks from /etc/ansible-init/playbooks")
for playbook in sorted(pathlib.Path("/etc/ansible-init/playbooks").glob("*.yml")):
    logger.info(f"  executing playbook - {playbook}")
    ansible_exec(
        "playbook",
        "--connection",
        "local",
        "--inventory",
        "127.0.0.1,",
        str(playbook)
    )


logger.info("executing remote playbooks for stage - post")
for playbook in playbooks:
    if playbook.get("stage", "post") == "post":
        logger.info(f"  executing playbook - {playbook['name']}")
        ansible_exec(
            "playbook",
            "--connection",
            "local",
            "--inventory",
            "127.0.0.1,",
            playbook["name"]
        )