#!/usr/bin/env python3
""" Display any failure messages for openstack servers in current terraform state. """
import json, subprocess, os, sys

def get_openstack_server(uuid):
    """ Return json with openstack server info """
    cmd = ['openstack', 'server', 'show', uuid, '-f', 'json']
    server_txt = subprocess.run(cmd, stdout=subprocess.PIPE, check=True, universal_newlines=True).stdout
    return json.loads(server_txt)

def read_tf_state(tf_dir):
    """ Return json from terraform state file in `tf_dir` """

    with open(os.path.join(tf_dir, 'terraform.tfstate')) as statef:
        state = json.load(statef)
    return state

def check_server_errors():
    tf_state = read_tf_state()
    for resource in tf_state['resources']:
        if resource['type'] == 'openstack_compute_instance_v2':
            for instance in resource['instances']:
                name = instance['attributes']['name']
                uuid = instance['attributes']['id']

                server = get_openstack_server(uuid)
                failure_msg = server.get('fault', {}).get('message')
                if failure_msg:
                    print(name, uuid, failure_msg)

if __name__ == '__main__':
    tf_dir = sys.argv[1] if len(sys.argv) > 1 else './'
    check_server_errors(tf_dir)
