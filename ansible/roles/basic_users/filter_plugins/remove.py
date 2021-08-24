""" Filter a dict to remove specified keys """

import copy


class FilterModule(object):

    def filters(self):
        return {
            'remove_keys': self.remove_keys
        }

    def remove_keys(self, orig_dict, keys_to_remove):
        '''Deletes items of dict by list of keys provided'''
        dict_to_return = copy.deepcopy(orig_dict)
        for item in keys_to_remove:
            if item in dict_to_return:
                del dict_to_return[item]
        return dict_to_return