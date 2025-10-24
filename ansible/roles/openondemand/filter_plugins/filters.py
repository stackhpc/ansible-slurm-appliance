#!/usr/bin/python
# pylint: disable=missing-module-docstring

# Copyright: (c) 2025, StackHPC
# Apache 2 License


def to_gres_options(stdout):
    """Convert sinfo output into a list of GRES options for an Ondemand `select`
    widget.

    Parameters:
      stdout: Text from `sinfo --noheader --format "%R %G"`

    Returns a list of [label, value] items. This is the format required for
    the `options` attribute of a `select` widget [1] where:
      - value (str) is a valid entry for the srun/sbatch --gres option [2].
      - label (str) is a user-friendly label with gres name, gres type and
        maximum gres count where relevant.
    The returned list will always include an entry for no GRES request.

    For example with a single GRES defined of `gpu:H200:8' the following
    entries are returned:
      - ['None', 'none']
      - ['Any gpu (max count=8, partitions=standard,long)', 'gpu']
      - ['H200 gpu (max count=8, partitions=standard,long)', 'gpu:H200']

    [1] https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/form-widgets.html#form-widgets
    [2] https://slurm.schedmd.com/srun.html#OPT_gres
    """  # noqa: E501 pylint: disable=line-too-long

    gres_data = {}
    # key=gres_opt - 'name' or 'name:type', i.e. what would be passed to --gres
    # value={label:str, max_count: int, partitions=[]}
    gres_data["none"] = {'label':'None', 'max_count':0, 'partitions':['all']}

    for line in stdout.splitlines():
        # line examples:
        # 'part1 gpu:H200:8(S:0-1),test:foo:1'
        # 'part2 (null)'
        # - First example shows multiple GRES per partition
        # - Core suffix e.g. '(S:0-1)' only exists for auto-detected gres
        # - stackhpc.openhpc role guarantees that name:type:count all exist
        partition, gres_definitions = (line.split())
        for gres in gres_definitions.split(","):
            if "(null)" in gres:
                continue
            gres_name, gres_type, gres_count_cores = gres.split(":", maxsplit=2)
            gres_count = gres_count_cores.split("(")[0]
            for gres_opt in [gres_name, f"{gres_name}:{gres_type}"]:
                if gres_opt not in gres_data:
                    label = (
                        f"{gres_type} {gres_name}"
                        if ":" in gres_opt
                        else f"Any {gres_opt}"
                    )
                    gres_data[gres_opt] = {'label':label, 'max_count':gres_count, 'partitions':[partition]}
                else:
                    gres_data[gres_opt]['partitions'].append(partition)
                    if gres_count > gres_data[gres_name]['max_count']:
                        gres_data[gres_opt]['max_count'] = gres_count

    gres_options = []
    for gres_opt in gres_data:  # pylint: disable=consider-using-dict-items
        max_count = gres_data[gres_opt]['max_count']
        partitions = gres_data[gres_opt]['partitions']
        label = gres_data[gres_opt]['label']
        if gres_opt != "none":
            label += f" (max count={max_count}, partitions={','.join(partitions)})"
        gres_options.append((label, gres_opt))
    return gres_options


# pylint: disable=useless-object-inheritance
# pylint: disable=too-few-public-methods
class FilterModule(object):
    """Ansible core jinja2 filters"""

    # pylint: disable=missing-function-docstring
    def filters(self):
        return {
            "to_gres_options": to_gres_options,
        }
