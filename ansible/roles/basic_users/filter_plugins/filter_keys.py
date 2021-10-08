""" Filter a dict to remove specified keys """

import copy


class FilterModule(object):

    def filters(self):
        return {
            'filter_keys': self.filter_keys
        }

    def filter_keys(self, orig_dict, keys_to_remove):
        ''' Return a copy of `orig_dict` without the keys in the list `keys_to_remove`'''
        dict_to_return = copy.deepcopy(orig_dict)
        for item in keys_to_remove:
            if item in dict_to_return:
                del dict_to_return[item]
        return dict_to_return