#!/usr/bin/env python
# Set github workflow output parameters defining image IDs from a packer manifest.
# Usage:
#   ./packer/read_manifest.py packer/packer-manifest.json

# E.g. assuming the default packer builds this will produce something like:
#   ::set-output name=NEW_COMPUTE_IMAGE_ID::9aabd73d-e550-4116-a90c-700478b722ce
#   ::set-output name=NEW_LOGIN_IMAGE_ID::87b41d58-d7e3-4c38-be05-453c3287ecab
#   ::set-output name=NEW_CONTROL_IMAGE_ID::7f812168-73fe-4a60-b9e9-9109a405390d
# which can be used in subsequent workflow steps: [1]
#
# [1]: https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#example-setting-a-value

import sys, json
output = {}
with open(sys.argv[1]) as f:
    data = json.load(f)
for build in data['builds']:
    node_type = build['custom_data']['source']
    image_id = build['artifact_id']
    output[node_type] = image_id # NB: this deliberately gets the LAST build for a node type
for node_type, image_id in output.items():
    print('::set-output name=NEW_%s_IMAGE_ID::%s' % (node_type.upper(), image_id))
