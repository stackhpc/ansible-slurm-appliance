ToDo.md

Do I need to change these in production? Probably not.
./environments/nrel/group_var/secrets.yml
   vault_elasticsearch_admin_password: hX0ZoJ_-lxnhFQ3EArp3
   vault_grafana_admin_password: IcnmebnZN1,333l.3S_w
   vault_mysql_root_password: IJi:0kCLyOaOcsTP-bxl
   vault_mysql_slurm_password: flhXhcJrKHN:nHqFXi4B


Get /etc/ssh/sshd_* files from login nodes


Add mail prog (postfix) re:
   error: Configured MailProg is invalid

remove login message:
Activate the web console with: systemctl enable --now cockpit.socket


These vars are defined in env/inventory/group_vars/all/cluster_name.yml
vermilion_cluster_name: vtest
vermilion_cluster_name_prefix: vtest


<!-- # Added to init - added to bashrc
/nopt/nrel/apps/csso/
/nopt/nrel/apps/modules/default/env.sh -->

So, two things...
<!--
1 remove firewalld from the deployed image -->

<!-- 2 make that dir before the slurm plays run: /var/spool/slurm/ -->

# 3 set hostname:
# cat /etc/hostname | cut -f1 -d"."
# "hostnamectl set-hostname {{ ansible_hostname }}"
### "hostnamectl set-hostname {{ ansible_hostname }}.vs.hpc.nrel.gov"
## -- > just: hostnamectl set-hostname {{ ansible_hostname }} -->

Add mail prog (postfix) re:
   error: Configured MailProg is invalid

# Add to init
/nopt/nrel/apps/csso/
/nopt/nrel/apps/modules/default/env.sh

So, two things...

1 remove firewalld from the deployed image

2 make that dir before the slurm plays run: /var/spool/slurm/

3 set hostname:
cat /etc/hostname | cut -f1 -d"."
"hostnamectl set-hostname {{ ansible_hostname }}"
## "hostnamectl set-hostname {{ ansible_hostname }}.vs.hpc.nrel.gov"



● slurmd.service - Slurm node daemon
   Loaded: loaded (/usr/lib/systemd/system/slurmd.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-12-01 18:13:09 MST; 1min 49s ago
 Main PID: 122403 (slurmd)
    Tasks: 1
   Memory: 1.6M
   CGroup: /system.slice/slurmd.service
           └─122403 /usr/sbin/slurmd -D -s --conf-server vtest-vtcontrol

Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov systemd[1]: Started Slurm node daemon.
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: slurmd: error: Node configuration differs from hardware: CPUs=1:8(hw) Boards=1:1(hw) SocketsPerBoard=1:1(hw) CoresPerSocket=1:8(hw) ThreadsPerCore=1:1(hw)
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: error: Node configuration differs from hardware: CPUs=1:8(hw) Boards=1:1(hw) SocketsPerBoard=1:1(hw) CoresPerSocket=1:8(hw) ThreadsPerCore=1:1(hw)
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: slurmd: slurmd version 22.05.2 started
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: Can not stat gres.conf file (/var/spool/slurm/slurmd/conf-cache/gres.conf), using slurm.conf data
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: CPU frequency setting not configured for this node
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: slurmd version 22.05.2 started
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: slurmd started on Thu, 01 Dec 2022 18:13:09 -0700
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: slurmd: CPUs=1 Boards=1 Sockets=1 Cores=1 Threads=1 Memory=16018 TmpDisk=0 Uptime=351003 CPUSpecList=(null) FeaturesAvail=(null) FeaturesActive=(null)
Dec 01 18:13:09 vtest-vtlogin-1.hpc.nrel.gov slurmd[122403]: CPUs=1 Boards=1 Sockets=1 Cores=1 Threads=1 Memory=16018 TmpDisk=0 Uptime=351003 CPUSpecList=(null) FeaturesAvail=(null) FeaturesActive=(null)
~
