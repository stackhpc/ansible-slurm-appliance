#!/usr/bin/env python

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

CLUSTER_RESOURCES = {
    "server": [],
    "port": [],
    "volume": ["--purge"],  # remove volume with snapshots
}


def delete_cluster(cluster_prefix, force=False):

    to_delete = {}
    for resource_type in CLUSTER_RESOURCES:
        to_delete[resource_type] = []
        resource_list = subprocess.run(
            f"openstack {resource_type} list --format json",
            stdout=subprocess.PIPE,
            shell=True,
            check=True,
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
        for resource_type, extra_args in CLUSTER_RESOURCES.items():
            items = [v["ID"] for v in to_delete[resource_type]]
            if items:
                cmd = ["openstack", resource_type, "delete", *extra_args, *items]
                # delete all resources of each type in a single call for speed:
                try:
                    subprocess.run(
                        cmd,
                        capture_output=True,
                        check=True,
                        encoding="utf-8",
                    )
                except subprocess.CalledProcessError as e:
                    print(
                        f"Error calling {e.cmd!r}: returncode={e.returncode} stdout={e.stdout} stderr={e.stderr}"
                    )
                    sys.exit(1)
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
