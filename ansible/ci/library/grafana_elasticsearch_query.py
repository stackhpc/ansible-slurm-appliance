#!/usr/bin/python


# Copyright: (c) 2022 Steve Brasier steve@stackhpc.com

import json

import requests
from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = r"""
---
module: grafana_elasticsearch_query

short_description: Get elasticsearch hits via grafana

version_added: "1.0.0"

description: Returns hits from selected datasource and indices.

author:
    - Steve Brasier
"""

EXAMPLES = r"""
- name: Get elasticsearch hits
  grafana_elasticsearch_query:
    grafana_url: http://{{ grafana_api_address }}:{{ grafana_port }}
    grafana_username: grafana
    grafana_password: "{{ vault_grafana_admin_password }}"
    datasource: slurmstats
    index_pattern: 'filebeat-*'
"""

RETURN = r"""
# These are examples of possible return values, and in general should use other names for return values.
docs:
  description: List of dicts with the original json in each document.
  returned: always
  type: list
"""


def run_module():
    module_args = {
        "grafana_url": {
            "type": "str",
            "required": True,
        },
        "grafana_username": {
            "type": "str",
            "required": True,
        },
        "grafana_password": {
            "type": "str",
            "required": True,
        },
        "datasource": {
            "type": "str",
            "required": True,
        },
        "index_pattern": {
            "type": "str",
            "required": True,
        },
    }

    result = {
        "changed": False,
        "jobs": [],
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    auth = (module.params["grafana_username"], module.params["grafana_password"])

    # list datasources:
    datasources_api_url = module.params["grafana_url"] + "/api/datasources"
    r = requests.get(datasources_api_url, auth=auth)
    datasources = json.loads(r.text)

    # select required datasource:
    ds = next(s for s in datasources if s["name"] == module.params["datasource"])

    # get documents:
    datasource_proxy_url = (
        module.params["grafana_url"]
        + "/api/datasources/proxy/"
        + str(ds["id"])
        + "/"
        + module.params["index_pattern"]
        + "/_search"
    )
    r = requests.get(datasource_proxy_url, auth=auth)
    search = json.loads(r.text)
    # see
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-api-response-body:
    docs = [h["_source"]["json"] for h in search["hits"]["hits"]]

    result = {
        "docs": docs,
    }

    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
