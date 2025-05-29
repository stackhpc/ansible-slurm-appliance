from ansible.module_utils.basic import AnsibleModule
import subprocess

DOCUMENTATION = r'''
module: dnf_module_info
description: Return a list of packages which would be installed by a dnf module
options:
    name:
        description: The dnf module name
        required: true
        type: str
    stream:
        description: The stream to query
        required: true
        type: str
'''

RETURN = r'''
info:
    description: The version/context etc for the module
    type: list
    returned: always
profiles:
    description: A mapping, keyed by profile name, where values are a list
                 of packages this profile will install
    type: dict
    returned: always
stdout:
    description: Raw stdout from the dnf command
    type: str
    returned: always
'''

def dnf_module_packages():
    module_args = dict(
        name=dict(type='str', required=True),
        stream=dict(type='str', required=True)
    )
    result = {'changed': False}

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
    dnf_module_name = module.params['name']
    dnf_module_stream = module.params['stream']

    # first get the list of packages installed by the module
    cmd = ['dnf', 'module', 'info', '--profile',  f'{dnf_module_name}:{dnf_module_stream}']
    dnf = subprocess.run(cmd,  capture_output=True, text=True)

    curr_profile_name = ''
    profiles = {}
    for line in dnf.stdout.splitlines():
        if line.startswith('Last'): # metadata expiration info
            continue
        elif not ':' in line:
            continue
        elif line.startswith('Name'):
            info = [v.strip() for v in line.split(':')]
        else:
            try:
                profile, pkg = (v.strip() for v in line.split(':'))
            except ValueError:
                raise ValueError(line)
            if profile != '' and profile != curr_profile_name:
                curr_profile_name = profile
                profiles[profile] = []
            profiles[curr_profile_name].append(pkg)


    result['info'] = info
    result['profiles'] = profiles
    result['stdout'] = dnf.stdout
    module.exit_json(**result)


if __name__ == '__main__':
    dnf_module_packages()
