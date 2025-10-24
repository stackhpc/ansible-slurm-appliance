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
      - ['Any gpu (max count: 8)', 'gpu']
      - ['H200 gpu' (max count: 8)', 'gpu:H200']

    [1] https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/form-widgets.html#form-widgets
    [2] https://slurm.schedmd.com/srun.html#OPT_gres
    """
    gres_data = (
        {}
    )  # k=gres_opt, v=[label, max_count] # where gres_opt is what would be passed to --gres
    gres_data["none"] = ["None", 0]

    for line in stdout.splitlines():
        partition, gres_definitions = (
            line.split()
        )  # e.g. 'part1 gpu:H200:8(S:0-1),test:foo:1', or 'part2 (null)'
        for gres in gres_definitions.split(","):
            if "(null)" in gres:
                continue
            gres_name, gres_type, gres_count_cores = gres.split(":", maxsplit=2)
            gres_count = gres_count_cores.split("(")[
                0
            ]  # may or may not have the e.g. '(S:0-1)' core definition
            for gres_opt in [gres_name, f"{gres_name}:{gres_type}"]:
                if gres_opt not in gres_data:
                    label = (
                        f"{gres_type} {gres_name}"
                        if ":" in gres_opt
                        else f"Any {gres_opt}"
                    )
                    gres_data[gres_opt] = [label, gres_count]
                elif len(gres_data[gres_name]) == 1:
                    raise ValueError(gres_data[gres_name])
                elif gres_count > gres_data[gres_name][1]:
                    gres_data[gres_opt][1] = gres_count

    gres_options = []
    for gres_opt in gres_data:
        max_count = gres_data[gres_opt][1]
        label = gres_data[gres_opt][0]
        if gres_opt != "none":
            label += f" (max count: {max_count})"
        gres_options.append((label, gres_opt))
    return gres_options


# pylint: disable=useless-object-inheritance
class FilterModule(object):
    """Ansible core jinja2 filters"""

    # pylint: disable=missing-function-docstring
    def filters(self):
        return {
            "to_gres_options": to_gres_options,
        }
