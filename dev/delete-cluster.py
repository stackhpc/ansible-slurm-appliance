#!/usr/bin/env python

"""
Delete infrastructure for a cluster without using Terraform. Useful for CI clusters.

Usage:
    delete-cluster.py PREFIX [--force]

Where PREFIX is the string at the start of the resource's names.
If --force is provided, it will delete all resources without confirmation.
"""

import sys, json, subprocess


CLUSTER_RESOURCES = ['server', 'port', 'volume']

def delete_cluster(cluster_prefix, force=False):
    to_delete = {}
    for resource_type in CLUSTER_RESOURCES:
        to_delete[resource_type] = []
        resource_list = subprocess.run(f'openstack {resource_type} list --format json', stdout=subprocess.PIPE, shell=True)
        resources = json.loads(resource_list.stdout)
        for item in resources:
            try:
                if item['Name'] is not None and item['Name'].startswith(cluster_prefix):
                    print(resource_type, item['Name'], item['ID'])
                    to_delete[resource_type].append(item)
            except:
                print(resource_type, item)
                raise
    
    if force or input('Delete these (y/n)?:') == 'y':
        for resource_type in CLUSTER_RESOURCES:
            items = [v['ID'] for v in to_delete[resource_type]]
            if items:
                # delete all resources of each type in a single call for speed:
                subprocess.run(f"openstack {resource_type} delete {' '.join(items)}", stdout=subprocess.PIPE, shell=True)
                print(f'Deleted {len(items)} {resource_type}s')
    else:
        print('Cancelled - no resources deleted')

if __name__ == '__main__':
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print('ERROR: Incorrect argument(s).\n' + __doc__)
        exit(1)
    force_flag = '--force' in sys.argv
    cluster_prefix = sys.argv[1]
    delete_cluster(cluster_prefix, force_flag)

