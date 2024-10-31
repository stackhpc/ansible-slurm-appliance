# persist_hostkeys

Save hostkeys to persistent storage and restore them after a rebuild/reimage.

Add hosts to the `persist_hostkeys` group to enable.

This role has no variables but hosts in this group must have `appliances_state_dir`
defined as a directory they can write to on persistent storage.
