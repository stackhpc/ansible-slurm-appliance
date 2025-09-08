# pylint: disable=missing-module-docstring
import requests  # pylint: disable=import-error
from ansible.module_utils.basic import AnsibleModule  # pylint: disable=import-error
from bs4 import BeautifulSoup  # pylint: disable=import-error, wrong-import-order

__metaclass__ = type  # pylint: disable=invalid-name

DOCUMENTATION = r"""
---
module: latest_timestamps
short_description: Gets the latest set of snapshots from Pulp
version_added: "1.0.0"
description: >
    Gets the latest set of snapshots from given source URLs
    and returns dictionary to replace 'appliances_repo_timestamps' with
author:
    - William Tripp
    - Steve Brasier
"""

EXAMPLES = r"""
- name: Get latest timestamps
  latest_timestamps:
    repos_dict: "{{ appliances_repo_timestamp_sources }}"
    content_url: "https://ark.stackhpc.com/pulp/content"
  register: result
"""

RETURN = r"""
latest_dict:
    description: Dictionary with updated timestamps
    type: dict
    returned: always
changed_timestamps:
    description: List of repos that have updated timestamps
    type: str[]
    returned: always
"""


def run_module():  # pylint: disable=missing-function-docstring
    module_args = {
        "repos_dict": {
            "type": "dict",
            "required": True,
        },
        "content_url": {
            "type": "str",
            "required": True,
        },
    }

    result = {
        "changed": False,
        "original_message": "",
        "message": "",
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    timestamps = dict(module.params["repos_dict"])
    for repo in timestamps:
        for version in timestamps[repo]:

            html_txt = requests.get(
                    url= module.params['content_url'] + '/' + timestamps[repo][version]['pulp_path']
                ).text
            timestamp_link_list = BeautifulSoup(html_txt,features="html.parser").body.find('pre').find_all() # getting raw list of timestamps from html
            timestamp_link_list = map(lambda x: x.string,timestamp_link_list) # stripping xml tags
            latest_timestamp = list(timestamp_link_list)[-1][:-1] # last timestamp in list with trailing / removed
            timestamps[repo][version]['pulp_timestamp'] = latest_timestamp
    result['timestamps'] = dict(sorted(timestamps.items()))

    module.exit_json(**result)


def main():  # pylint: disable=missing-function-docstring
    run_module()


if __name__ == "__main__":
    main()
