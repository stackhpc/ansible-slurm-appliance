


# Users

The dicts in `freeipa_users` take any parameters for the [community.general.ipa_user](https://docs.ansible.com/ansible/latest/collections/community/general/ipa_user_module.html#ansible-collections-community-general-ipa-user-module). Note that:
    - Parameters `name`, `givenname` (firstname) and `sn` (surname) are required.
    - Parameters `ipa_pass` and `ipa_user` are automatically set by the role.
    - The uid and gid are automatically set by FreeIPA.
    - If `password` is set, the value should *not* be a hash (unlike `ansible.builtin.user` as used by the `basic_users` role), and it must be changed on first login unless `krbpasswordexpiration` is set to some future date.
