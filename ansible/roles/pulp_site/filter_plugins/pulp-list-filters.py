class FilterModule(object):
    def filters(self):
        return {
            'to_rpm_repos': self.to_rpm_repos,
            'to_rpm_pubs': self.to_rpm_pubs,
            'to_rpm_distros': self.to_rpm_distros,
            'select_repos': self.select_repos,
        }
    
    def select_repos(self, dnf_repos, target_distro_ver): #TODO: why does baseos get a major and minor version?
        """ Filter dnf_repos to only those for a relevant distribution version (M.m or M). Returns a list of dicts.
            TODO: note this adds distro_ver as a key
        """
    
        target_distro_ver_major = target_distro_ver.split('.')[0]

        rpm_repos = []
        for repokey in dnf_repos:
            # select either the matching major.minor or major version:
            if target_distro_ver in dnf_repos[repokey]:
                selected_ver = target_distro_ver
            elif target_distro_ver_major in dnf_repos[repokey]:
                selected_ver = target_distro_ver_major
            else:
                raise ValueError(f'No key matching {target_distro_ver_major} or {target_distro_ver} found in f{repokey}')
            repo_data = dnf_repos[repokey][selected_ver]
            repo_data['distro_ver'] = selected_ver
            rpm_repos.append(repo_data)
        return rpm_repos

    def to_rpm_repos(self, rpm_info, content_url, repo_defaults):
        """ TODO """
        rpm_repos = []
        for repo_data in rpm_info:
            rpm_data = repo_defaults.copy() # NB: this changes behaviour vs before, so now defaults can correctly be overriden
            rpm_data['name'] = get_repo_name(repo_data)
            rpm_data['url'] = '/'.join([content_url, repo_data['pulp_path'], repo_data['pulp_timestamp']])
            rpm_data['state'] = 'present'
            rpm_repos.append(rpm_data)
        return rpm_repos

    def to_rpm_pubs(self, list):
        pub_list = map(lambda x: {
            'repository': get_repo_name(x),
            'state': 'present' }, list)
        return pub_list
    
    def to_rpm_distros(self, list):
        distro_list = map(lambda x: {
            'name': x['pulp_repo_name'],
            'repository': get_repo_name(x),
            'base_path': x['pulp_path'],
            'state': 'present' }, list)
        return distro_list

def get_repo_name(dnf_repos_data):
    return f"{dnf_repos_data['pulp_repo_name']}-{dnf_repos_data['distro_ver']}-{dnf_repos_data['pulp_timestamp']}"
