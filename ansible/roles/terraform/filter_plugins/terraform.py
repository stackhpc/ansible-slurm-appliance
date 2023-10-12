import re

def expand_hostlist(hostlist):
    match =  re.search(r'(\w+)-\[(\d+)-(\d+)\]', hostlist)
    if match:
        prefix = match.groups()[0]
        start, end = [int(v) for v in match.groups()[1:]]
        hosts = [f'{prefix}-{n}' for n in range(start, end+1)]
        return hosts
    else:
        return [hostlist,]

class FilterModule(object):
    def filters(self):
        return {
            'expand_hostlist': expand_hostlist,
        }
