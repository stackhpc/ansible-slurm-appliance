#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

from ansible.errors import AnsibleError, AnsibleFilterError
from collections import defaultdict
import jinja2
from ansible.module_utils.six import string_types
import os.path

def readfile(fpath):
    if not os.path.isfile(fpath):
        return ""
    with open(fpath) as f:
        return f.read()

class FilterModule(object):
    ''' Ansible core jinja2 filters '''

    def filters(self):
        return {
            # jinja2 overrides
            'readfile': readfile
        }