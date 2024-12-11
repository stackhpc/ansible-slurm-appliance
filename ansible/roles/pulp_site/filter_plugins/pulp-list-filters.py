class FilterModule(object):
    def filters(self):
        return {
            'to_rpm_repos': self.to_rpm_repos,
            'to_rpm_pubs': self.to_rpm_pubs,
            'to_rpm_distros': self.to_rpm_distros
        }

    def to_rpm_repos(self, list):
        repo_list = map(lambda x: {
            'name': x['name'],
            'url': x['url'],
            'remote_username': x['remote_username'],
            'remote_password': x['remote_password'],
            'policy': x['policy'],
            'state': x['state'] }, list)
        return repo_list
    
    def to_rpm_pubs(self, list):
        pub_list = map(lambda x: {
            'repository': x['name'],
            'state': x['state'] }, list)
        return pub_list
    
    def to_rpm_distros(self, list):
        distro_list = map(lambda x: {
            'name': x['name'],
            'repository': x['name'],
            'base_path': x['base_path'],
            'state': x['state'] }, list)
        return distro_list