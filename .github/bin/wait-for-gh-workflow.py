#!/usr/bin/env python3
"""
Wait for a github workflow run on a specific branch and sha to succeed.

Use -h to see usage.
"""

import argparse
import json
import subprocess
import time


def get_runs(workflow, branch):
    """ get runs for a particular workflow and branch """
    gh_run_cmd = [
        "gh",
        "run",
        "list",
        "--workflow",
        workflow,
        "--branch",
        branch,
        "--json",
        "headSha,conclusion,databaseId",
    ]
    p = subprocess.run(gh_run_cmd, text=True, capture_output=True)
    if p.returncode > 0:
        print("ERROR command:", gh_run_cmd)
        print("ERROR stderr:", p.stderr)
        exit(1)
    values = json.loads(p.stdout)
    return values


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("workflow", help="workflow name")
    parser.add_argument("branch", help="branch name to match")
    parser.add_argument("sha", help="git hash to match")
    parser.add_argument(
        "-t", "--timeout", default=600, type=int, help="total seconds to wait"
    )
    parser.add_argument(
        "-d", "--delay", default=10, type=int, help="seconds to wait between checks"
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="show all runs")
    args = parser.parse_args()
    if args.verbose:
        print(args)

    t_start = time.time()
    t_end = t_start + args.timeout
    while time.time() < t_end:

        runs = get_runs(args.workflow, args.branch)
        if args.verbose:
            print(runs)
        for run in runs:
            if run["headSha"] == args.sha and run["conclusion"] == "success":
                print("found:", run)
                exit()
        time.sleep(args.delay)
    print("no match")
    exit(1)
