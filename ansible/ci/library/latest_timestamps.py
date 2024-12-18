#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: latest_timestamps

short_description: Gets the latest set of snapshots from Pulp and overwrites

version_added: "1.0.0"

description: Gets the latest set of snapshots from given source URLs and returns dictionary in to replace 'appliances_repo_timestamps' with

author:
    - William Tripp
'''

EXAMPLES = r'''
# Pass in a message
- name: Get latest timestamps
  latest_timestamps:
    current_timestamps_dict: "{{ appliances_repo_timestamps }}"
    sources_dict: "{{ appliances_repo_timestamp_sources }}"
  register: result

'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
latest_dict:
    description: Dictionary with updated timestamps
    type: dict
    returned: always
changed_timestamps:
    description: List of repos that've been updated
    type: str[]
    returned: always
'''

from ansible.module_utils.basic import AnsibleModule
import requests
from bs4 import BeautifulSoup

def run_module():
    module_args = dict(
        current_timestamps_dict=dict(type='dict', required=True),
        sources_dict=dict(type='dict', required=True)
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    latest_timestamps = {}
    changed_timestamps = []
    for repo in module.params['sources_dict']:
        latest_timestamps[repo] = module.params['sources_dict'][repo]
        for version in module.params['sources_dict'][repo]:
            html_txt = requests.get(url=module.params['sources_dict'][repo][version]).text
            timestamp_link_list = BeautifulSoup(html_txt,features="html.parser").body.find('pre').find_all()
            timestamp_link_list = map(lambda x: x.string,timestamp_link_list) # xml tags
            latest_timestamps[repo][version] = list(timestamp_link_list)[-1][:-1] # last timestamp in list with trailing / removed
            if module.params['sources_dict'][repo][version] != module.params['current_timestamps_dict'][repo][version]:
                changed_timestamps.append(repo+' '+version)

    result['latest_dict'] = latest_timestamps
    result['changed_timestamps'] = changed_timestamps

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()