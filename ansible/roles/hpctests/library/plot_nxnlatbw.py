#!/usr/bin/env python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.module_utils.basic import AnsibleModule
import json

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
description:
    - "Reads output from running the nxnlatbw ping matrix. Return value includes a 'stats' key with min/max latency and bandwidth values. Generates an html table of pairwise latencies, coloured by value."
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
        description:
            - Comma-separated list of nodenames to label RANKS with - NB this should be provided in the same order as ranks
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
<p>Min latency: {min_lat} &#181;s (white)</p>
<p>Max latency: {max_lat} &#181;s (red)</p>
<table>
<tr><td>#</td> {ranks} </tr>
{rows}
</table>
</body>
</html>
"""

def run_module():
    module_args = dict(
        src=dict(type="str", required=True),
        dest=dict(type="str", required=True),
        nodes=dict(type="str", required=False, default=None)
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    result = {"changed": False}
    
    src = module.params["src"]
    dest = module.params["dest"]
    nodes = module.params["nodes"]
    if nodes is not None:
        nodes = nodes.split(',')
    
    if module.check_mode:
        module.exit_json(**result)

     # read latencies/bandwidths:
    latencies = {}
    bandwidths = {}
    with open(src) as nxn_f:
        for ln, line in enumerate(nxn_f):
            vals = line.split(',')
            if vals[0] == 'src':
                continue
            if len(vals) != 4:
                print('warning: skipping line %i (%i values)' % (ln, len(vals)))
                continue
            rankA, rankB, lat, bw = int(vals[0]), int(vals[1]), float(vals[2]), float(vals[3])
            latencies[rankA, rankB] = lat
            bandwidths[rankA, rankB] = bw
    
    # get list of node IDs:
    rankAs = sorted(set(k[0] for k in latencies))
    rankBs = sorted(set(k[1] for k in latencies))
    if rankAs != rankBs:
        module.fail_json("Ranks extracted from result columns differed", **result)
    if nodes and len(nodes) != len(rankAs):
        module.fail_json("Results contained %i ranks but %i node names provided" % (len(rankAs), len(nodes)), **result)

    # find min values:
    min_lat = min(latencies.values())
    max_lat = max(latencies.values())
    min_bw = min(bandwidths.values())
    max_bw = max(bandwidths.values())
    
    # create HTML fragments:
    ranks = ' '.join('<td>%s</td>' % rankB for rankB in rankBs)
    rows = []
    for rankA in rankAs: # row
        if nodes:
            outrow = ['<tr><td>%s [%s]</td>' % (nodes[rankA], rankA)]
        else:
            outrow = ['<tr><td>%s</td>' % rankA]
        for rankB in rankBs:
            val = latencies.get((rankA, rankB))
            if val is not None:
                lightness = 50 + (50 - 50 * ((val - min_lat) / (max_lat - min_lat))) # want value in range LOW = 100 (white) -> HIGH 50(red)
                outrow += ['<td style="background-color:hsl(0, 100%%, %i%%);">%.1f</td>' % (lightness, val)]
            else:
                outrow += ['<td>-</td>']
        outrow += ['</tr>']
        rows.append(' '.join(outrow))
    rows = '\n'.join(rows)

    page = HTML_TEMPLATE.format(min_lat=min_lat, max_lat=max_lat, ranks=ranks, rows=rows)

    with open(dest, 'w') as outf:
        outf.write(page)

    result['changed'] = True
    result['stats'] = {
        'min_latency (us)': min_lat,
        'max_latency (us)': max_lat,
        'min_bandwidth (MB/s)': min_bw,
        'max_bandwidth (MB/s)': max_bw,
    }

    module.exit_json(**result)


def main():
    run_module()

if __name__ == "__main__":
    main()
