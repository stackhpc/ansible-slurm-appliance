#!/usr/bin/python

# Copyright: (c) 2022 Steve Brasier steve@stackhpc.com
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import requests
import json

DOCUMENTATION = r'''
---
module: user_namepace_facts

short_description: Returns subgid and subuid maps

version_added: "1.0.0"

description: Returns subgid and subuid maps.

author:
    - Will Szumski (@jovial)
'''

EXAMPLES = r'''
- name: Return ansible_facts
  user_namepace_facts:
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
ansible_facts:
  description: Facts to add to ansible_facts.
  returned: always
  type: dict
  contains:
    subuid:
      description: Parsed output of /etc/subuid
      type: str
      returned: always, empty dict if /etc/subuid doesn't exist
      sample: { "foo": {"size": 123, "start": 100000 }}
    subgid:
      description: Parsed output of /etc/subgid
      type: str
      returned: always, empty dict if /etc/subgid doesn't exist
      sample: { "foo": {"size": 123, "start": 100000 }}
'''

from ansible.module_utils.basic import AnsibleModule
import csv
import os

def run_module():
    module_args = dict(
        grafana_url=dict(type="str", required=True),
        grafana_username=dict(type="str", required=True),
        grafana_password=dict(type="str", required=True),
        datasource=dict(type="str", required=True),
        index_pattern=dict(type="str", required=True),
    )

    result = dict(
        changed=False,
        jobs=[]
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    auth=(module.params['grafana_username'], module.params['grafana_password'])
    
    # list datasources:
    datasources_api_url = module.params["grafana_url"] + '/api/datasources'
    r = requests.get(datasources_api_url, auth=auth)
    datasources = json.loads(r.text)

    # select required datasource:
    ds = [s for s in datasources if s['name'] == module.params["datasource"]][0]

    # get documents:
    datasource_proxy_url = module.params["grafana_url"] + '/api/datasources/proxy/' + str(ds['id']) + '/' + module.params['index_pattern'] + '/_search'
    r = requests.get(datasource_proxy_url, auth=auth)
    search = json.loads(r.text)
    # see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-api-response-body:
    docs = [h['_source']['json'] for h in search['hits']['hits']]    

    result = {
        'docs': docs,
    }

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
