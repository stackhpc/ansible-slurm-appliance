#!/usr/bin/env python
# pylint: disable=invalid-name

"""
Delete infrastructure for a cluster without using Terraform. Useful for CI clusters.

Usage:
    delete-cluster.py PREFIX [--force]

Where PREFIX is the string at the start of the resource's names.
If --force is provided, it will delete all resources without confirmation.
"""

import argparse
import json
import subprocess
import sys

CLUSTER_RESOURCES = ["server", "port", "volume"]


# pylint: disable-next=missing-function-docstring, redefined-outer-name
def delete_cluster(cluster_prefix, force=False):

    to_delete = {}
    for resource_type in CLUSTER_RESOURCES:
        to_delete[resource_type] = []
        resource_list = subprocess.run(  # pylint: disable=subprocess-run-check
            f"openstack {resource_type} list --format json",
            stdout=subprocess.PIPE,
            shell=True,
        )
        resources = json.loads(resource_list.stdout)
        for item in resources:
            try:
                if item["Name"] is not None and item["Name"].startswith(cluster_prefix):
                    print(resource_type, item["Name"], item["ID"])
                    to_delete[resource_type].append(item)
            except BaseException:
                print(resource_type, item)
                raise

    if force or input("Delete these (y/n)?:") == "y":
        for resource_type in CLUSTER_RESOURCES:
            items = [v["ID"] for v in to_delete[resource_type]]
            if items:
                # delete all resources of each type in a single call for speed:
                subprocess.run(  # pylint: disable=subprocess-run-check
                    f"openstack {resource_type} delete {' '.join(items)}",
                    stdout=subprocess.PIPE,
                    shell=True,
                )
                print(f"Deleted {len(items)} {resource_type}s")
    else:
        print("Cancelled - no resources deleted")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="don't ask for confirmation before deleting",
    )
    parser.add_argument("cluster_prefix")
    args = parser.parse_args()
    if not args.cluster_prefix:
        print("ERROR: empty cluster prefix is not allowed", file=sys.stderr)
        sys.exit(1)
    delete_cluster(args.cluster_prefix, args.force)
