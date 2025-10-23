#!/usr/bin/python
# pylint: disable=missing-module-docstring

# Copyright: (c) 2025, StackHPC
# Apache 2 License

def to_gres_options(stdout):
  gres_data = {} # k=gres_opt, v=[label, max_count] # where gres_opt is what would be passed to --gres
  gres_data['none'] = ['None', 0]
  
  for line in stdout.splitlines():
      if '(null)' in line:
          continue
      partition, gres = line.split(' ')
      gres_name, gres_type, gres_number_cores = gres.split(':', maxsplit=2)
      gres_count, gres_cores = gres_number_cores.split('(')

      for gres_opt in [gres_name, f'{gres_name}:{gres_type}']:
          if gres_opt not in gres_data:
              label = f'{gres_type} {gres_name}' if ':' in gres_opt else f'Any {gres_opt}'
              gres_data[gres_opt] = [label, gres_count]
          elif gres_count > gres_data[gres_name][1]:
              gres_data[gres_opt][1] = gres_count
  gres_options = []
  for gres_opt in gres_data:
      max_count = gres_data[gres_opt][1]
      label = gres_data[gres_opt][0]
      if gres_opt != 'none':
          label += f' (max count: {max_count})'
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
