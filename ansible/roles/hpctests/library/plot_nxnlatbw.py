#!/usr/bin/python # pylint: disable=missing-module-docstring
# -*- coding: utf-8 -*-

# Copyright: (c) 2020, StackHPC
# Apache 2 License

import os

from ansible.module_utils.basic import AnsibleModule  # pylint: disable=import-error

ANSIBLE_METADATA = {
    "metadata_version": "0.1",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: plot_nxnlatbw
short_description: Read nxnlatbw output, report statistics and tabulate latencies
version_added: "0.0"
description: >
    Reads output from running the nxnlatbw ping matrix.
    Return value includes a 'stats' key with min/max latency and bandwidth values.
    Generates an html table of pairwise latencies, coloured by value.
options:
    src:
        description:
            - Path to output from nxnlatbw
        required: true
        type: str
    dest:
        description:
            - Path to write html file with latency table
        required: true
        type: str
   nodes:
        description: >
            Comma-separated list of nodenames to label RANKS with -
            NB this should be provided in the same order as ranks
requirements:
    - "python >= 3.6"
author:
    - Steve Brasier, StackHPC
"""

EXAMPLES = """
- name: Read pingpong
  read_imb_pingpong:
    path: /mnt/nfs/examples/pingpong.out
"""

HTML_TEMPLATE = """
<html>
<head></head>
<body>
<table>
<caption>Latency (&#181;s): min {min_lat} (white), max {max_lat} (red)</caption>
<tr><td>#</td> {ranks} </tr>
{lat_rows}
</table>
<p></p>
<table>
<caption>Bandwidth (MB/s): min {min_bw} (white), max {max_bw} (red)</caption>
<tr><td>#</td> {ranks} </tr>
{bw_rows}
</body>
</html>
"""


def html_rows(
    rankAs, rankBs, nodes, data
):  # pylint: disable=invalid-name # pylint: disable=invalid-name
    """Create an HTML-format fragment defining table rows.

    Args:
        rankAs, rankBs: lists of ranks
        nodes: list of nodenames in rank order
        data: dict with keys (rankA, rankB)

    Returns a string.
    """

    minv = min(data.values())
    maxv = max(data.values())

    rows = []
    for rankA in rankAs:  # row # pylint: disable=invalid-name
        if nodes:
            outrow = [
                # pylint: disable-next=consider-using-f-string
                "<tr><td>%s [%s]</td>"
                % (nodes[rankA], rankA)
            ]
        else:
            outrow = [
                # pylint: disable-next=consider-using-f-string
                "<tr><td>%s</td>"
                % rankA
            ]
        for rankB in rankBs:  # pylint: disable=invalid-name
            val = data.get((rankA, rankB))
            if val is not None:
                try:
                    lightness = 50 + (
                        50 - 50 * ((val - minv) / (maxv - minv))
                    )  # want value in range LOW = 100 (white) -> HIGH 50(red)
                except ZeroDivisionError:  # no min-max spread
                    lightness = 100
                outrow += [
                    # pylint: disable-next=consider-using-f-string
                    '<td style="background-color:hsl(0, 100%%, %i%%);">%.1f</td>'
                    % (lightness, val)
                ]
            else:
                outrow += ["<td>-</td>"]
        outrow += ["</tr>"]
        rows.append(" ".join(outrow))
    return "\n".join(rows)


def run_module():  # pylint: disable=missing-function-docstring, too-many-locals
    module_args = {
        "src": {
            "type": "str",
            "required": True,
        },
        "dest": {
            "type": "str",
            "required": True,
        },
        "nodes": {
            "type": "str",
            "required": False,
            "default": None,
        },
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}

    src = os.path.expanduser(module.params["src"])
    dest = os.path.expanduser(module.params["dest"])
    nodes = module.params["nodes"]
    if nodes is not None:
        nodes = nodes.split(",")

    if module.check_mode:
        module.exit_json(**result)

    # read latencies/bandwidths:
    latencies = {}
    bandwidths = {}
    with open(src) as nxn_f:  # pylint: disable=unspecified-encoding
        for ln, line in enumerate(nxn_f):
            vals = line.split(",")
            if vals[0] == "src":
                continue
            if len(vals) != 4:
                print(
                    # pylint: disable-next=consider-using-f-string
                    "warning: skipping line %i (%i values)"
                    % (ln, len(vals))
                )
                continue
            # pylint: disable=invalid-name
            try:
                (
                    rankA,
                    rankB,
                    lat,
                    bw,
                ) = (
                    int(vals[0]),
                    int(vals[1]),
                    float(vals[2]),
                    float(vals[3]),
                )
            except ValueError:
                print(f"warning: skipping line {ln} ({line}) - parse failure")
                continue
            latencies[rankA, rankB] = lat
            bandwidths[rankA, rankB] = bw
            # pylint: enable=invalid-name

    # get list of node IDs:
    rankAs = sorted(set(k[0] for k in latencies))  # pylint: disable=invalid-name
    rankBs = sorted(set(k[1] for k in latencies))  # pylint: disable=invalid-name
    if rankAs != rankBs:
        module.fail_json("Ranks extracted from result columns differed", **result)
    if nodes and len(nodes) != len(rankAs):
        module.fail_json(
            "Results contained %i ranks but %i node names provided"  # pylint: disable=consider-using-f-string
            % (len(rankAs), len(nodes)),
            **result,
        )

    # find min values:
    min_lat = min(latencies.values())
    max_lat = max(latencies.values())
    min_bw = min(bandwidths.values())
    max_bw = max(bandwidths.values())

    # create HTML fragments:
    ranks = " ".join(
        # pylint: disable-next=consider-using-f-string
        "<td>%s</td>" % rankB
        for rankB in rankBs
    )

    lat_rows = html_rows(rankAs, rankBs, nodes, latencies)
    bw_rows = html_rows(rankAs, rankBs, nodes, bandwidths)

    page = HTML_TEMPLATE.format(
        min_lat=min_lat,
        max_lat=max_lat,
        min_bw=min_bw,
        max_bw=max_bw,
        ranks=ranks,
        lat_rows=lat_rows,
        bw_rows=bw_rows,
    )

    with open(dest, "w") as outf:  # pylint: disable=unspecified-encoding
        outf.write(page)

    result["changed"] = True
    result["stats"] = {
        "min_latency (us)": min_lat,
        "max_latency (us)": max_lat,
        "min_bandwidth (MB/s)": min_bw,
        "max_bandwidth (MB/s)": max_bw,
        "min_bandwidth (Gbit/s)": min_bw / 125.0,
        "max_bandwidth (Gbit/s)": max_bw / 125.0,
    }

    module.exit_json(**result)


def main():  # pylint: disable=missing-function-docstring
    run_module()


if __name__ == "__main__":
    main()
