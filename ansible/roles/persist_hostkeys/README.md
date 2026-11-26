# persist_hostkeys

Idempotently generates a persistent set of hostkeys and restores them after a rebuild/reimage.

Add hosts to the `persist_hostkeys` group to enable. All hosts in group will have persisted hostkeys after a rebuild.

Set `persist_hostkeys_mode` to shared to make all hosts share the same persisted key. Otherwise, the persisted keys will be individual.
