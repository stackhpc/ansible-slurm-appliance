""" Filter a dict to remove specified keys """

import copy

USER_MODULE_PARAMS = ('append authorization comment create_home createhome expires force generate_ssh_key group '
                      'groups hidden home local login_class move_home name user non_unique password password_expire_min '
                      'password_expire_max password_lock profile remove role seuser shell skeleton ssh_key_bits '
                      'ssh_key_comment ssh_key_file ssh_key_passphrase ssh_key_type state system uid update_password').split()

class FilterModule(object):

    def filters(self):
        return {
            'filter_user_params': self.filter_user_params
        }

    def filter_user_params(self, d):
        ''' Return a copy of dict `d` containing only keys which are parameters for the user module'''
        
        user_dict = copy.deepcopy(d)
        remove_keys = set(user_dict).difference(USER_MODULE_PARAMS)
        for key in remove_keys:
            del user_dict[key]
        return user_dict
