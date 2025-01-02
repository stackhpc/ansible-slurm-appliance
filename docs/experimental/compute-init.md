# compute-init

See the role README.md

# Results/progress

Without any metadata:

    [root@rl9-compute-0 rocky]# systemctl status ansible-init
    ● ansible-init.service
        Loaded: loaded (/etc/systemd/system/ansible-init.service; enabled; preset: disabled)
        Active: activating (start) since Fri 2024-12-13 20:41:16 UTC; 1min 45s ago
    Main PID: 16089 (ansible-init)
        Tasks: 8 (limit: 10912)
        Memory: 99.5M
            CPU: 11.687s
        CGroup: /system.slice/ansible-init.service
                ├─16089 /usr/lib/ansible-init/bin/python /usr/bin/ansible-init
                ├─16273 /usr/lib/ansible-init/bin/python3.9 /usr/lib/ansible-init/bin/ansible-playbook --connection local --inventory 127.0.0.1, /etc/ansible-init/playbooks/1-compute-init.yml
                ├─16350 /usr/lib/ansible-init/bin/python3.9 /usr/lib/ansible-init/bin/ansible-playbook --connection local --inventory 127.0.0.1, /etc/ansible-init/playbooks/1-compute-init.yml
                ├─16361 /bin/sh -c "/usr/bin/python3 /root/.ansible/tmp/ansible-tmp-1734122485.9542894-16350-45936546411977/AnsiballZ_mount.py && sleep 0"
                ├─16362 /usr/bin/python3 /root/.ansible/tmp/ansible-tmp-1734122485.9542894-16350-45936546411977/AnsiballZ_mount.py
                ├─16363 /usr/bin/mount /mnt/cluster
                └─16364 /sbin/mount.nfs 192.168.10.12:/exports/cluster /mnt/cluster -o ro,sync

    Dec 13 20:41:24 rl9-compute-0.rl9.invalid ansible-init[16273]: ok: [127.0.0.1]
    Dec 13 20:41:24 rl9-compute-0.rl9.invalid ansible-init[16273]: TASK [Report skipping initialization if not compute node] **********************
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: skipping: [127.0.0.1]
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: TASK [meta] ********************************************************************
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: skipping: [127.0.0.1]
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: TASK [Ensure the mount directory exists] ***************************************
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid python3[16346]: ansible-file Invoked with path=/mnt/cluster state=directory owner=root group=root mode=u=rwX,go= recurse=False force=False follow=True modification_time_format=%Y%m%d%H%M.%S access>
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: changed: [127.0.0.1]
    Dec 13 20:41:25 rl9-compute-0.rl9.invalid ansible-init[16273]: TASK [Mount /mnt/cluster] ******************************************************
    Dec 13 20:41:26 rl9-compute-0.rl9.invalid python3[16362]: ansible-mount Invoked with path=/mnt/cluster src=192.168.10.12:/exports/cluster fstype=nfs opts=ro,sync state=mounted boot=True dump=0 passno=0 backup=False fstab=None
    [root@rl9-compute-0 rocky]# systemctl status ansible-init

Added metadata via horizon: 

    compute_groups ["compute"]


OK:

    [root@rl9-compute-0 rocky]# systemctl status ansible-init
    ● ansible-init.service
        Loaded: loaded (/etc/systemd/system/ansible-init.service; enabled; preset: disabled)
        Active: active (exited) since Fri 2024-12-13 20:43:31 UTC; 33s ago
        Process: 16089 ExecStart=/usr/bin/ansible-init (code=exited, status=0/SUCCESS)
    Main PID: 16089 (code=exited, status=0/SUCCESS)
            CPU: 13.003s

    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]: ok: [127.0.0.1] => {
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]:     "msg": "Skipping compute initialization as cannot mount exports/cluster share"
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]: }
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]: TASK [meta] ********************************************************************
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]: PLAY RECAP *********************************************************************
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16273]: 127.0.0.1                  : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=1
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16089]: [INFO] executing remote playbooks for stage - post
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16089]: [INFO] writing sentinel file /var/lib/ansible-init.done
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid ansible-init[16089]: [INFO] ansible-init completed successfully
    Dec 13 20:43:31 rl9-compute-0.rl9.invalid systemd[1]: Finished ansible-init.service.

Now run site.yml, then restart ansible-init again:


    [root@rl9-compute-0 rocky]# systemctl status ansible-init
    ● ansible-init.service
        Loaded: loaded (/etc/systemd/system/ansible-init.service; enabled; preset: disabled)
        Active: active (exited) since Fri 2024-12-13 20:50:10 UTC; 11s ago
        Process: 18921 ExecStart=/usr/bin/ansible-init (code=exited, status=0/SUCCESS)
    Main PID: 18921 (code=exited, status=0/SUCCESS)
            CPU: 8.240s

    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: TASK [Report skipping initialization if cannot mount nfs] **********************
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: skipping: [127.0.0.1]
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: TASK [meta] ********************************************************************
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: skipping: [127.0.0.1]
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: PLAY RECAP *********************************************************************
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[19110]: 127.0.0.1                  : ok=3    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[18921]: [INFO] executing remote playbooks for stage - post
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[18921]: [INFO] writing sentinel file /var/lib/ansible-init.done
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid ansible-init[18921]: [INFO] ansible-init completed successfully
    Dec 13 20:50:10 rl9-compute-0.rl9.invalid systemd[1]: Finished ansible-init.service.
    [root@rl9-compute-0 rocky]# ls /mnt/cluster/host
    hosts     hostvars/ 
    [root@rl9-compute-0 rocky]# ls /mnt/cluster/hostvars/rl9-compute-
    rl9-compute-0/ rl9-compute-1/ 
    [root@rl9-compute-0 rocky]# ls /mnt/cluster/hostvars/rl9-compute-
    rl9-compute-0/ rl9-compute-1/ 
    [root@rl9-compute-0 rocky]# ls /mnt/cluster/hostvars/rl9-compute-0/
    hostvars.yml

This commit - shows that hostvars have loaded:

    [root@rl9-compute-0 rocky]# systemctl status ansible-init
    ● ansible-init.service
        Loaded: loaded (/etc/systemd/system/ansible-init.service; enabled; preset: disabled)
        Active: active (exited) since Fri 2024-12-13 21:06:20 UTC; 5s ago
        Process: 27585 ExecStart=/usr/bin/ansible-init (code=exited, status=0/SUCCESS)
    Main PID: 27585 (code=exited, status=0/SUCCESS)
            CPU: 8.161s

    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]: TASK [Demonstrate hostvars have loaded] ****************************************
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]: ok: [127.0.0.1] => {
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]:     "prometheus_version": "2.27.0"
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]: }
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]: PLAY RECAP *********************************************************************
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27769]: 127.0.0.1                  : ok=5    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27585]: [INFO] executing remote playbooks for stage - post
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27585]: [INFO] writing sentinel file /var/lib/ansible-init.done
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid ansible-init[27585]: [INFO] ansible-init completed successfully
    Dec 13 21:06:20 rl9-compute-0.rl9.invalid systemd[1]: Finished ansible-init.service.
