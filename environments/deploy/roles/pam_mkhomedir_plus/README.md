# pam_mkhomedir_plus
Make user directories and additional paths at login.  The standard pam_mkhomedir pam module will only create /home directories, this pam module allows you to customize what path it creates (Example: /scratch).  You can use multiple lines in your pam config to create multiple directories if needed.

Build from source
===

Build requirements

```
yum install gcc pam-devel
```

RPM build requirements

```
easy_install pip
pip install scons && yum install rpm-build
```

How to build and install from source

```bash
make clean && make && make install
```

How to build the RPM

```bash
make rpm
```

Easy Install
===

```bash
yum install https://mirrors.hpc.nrel.gov/nrel/x86_64/pam_mkhomedir_plus-0.0.1-0.x86_64.rpm
```

Here is a sample /etc/pam.d/system-auth file (Do not overwrite your system config, use as an example and modify the system config based on the below example)

```   
auth       required pam_env.so
auth       required pam_faildelay.so delay=2000000
auth       [default=1 ignore=ignore success=ok] pam_succeed_if.so uid >= 1000 quiet
auth       [default=1 ignore=ignore success=ok] pam_localuser.so
auth       sufficient pam_unix.so nullok try_first_pass
auth       requisite pam_succeed_if.so uid >= 1000 quiet_success
auth       sufficient pam_sss.so forward_pass
auth       required pam_deny.so

account    required pam_unix.so
account    sufficient pam_localuser.so
account    sufficient pam_succeed_if.so uid < 1000 quiet
account    [default=bad success=ok user_unknown=ignore] pam_sss.so
account    required pam_permit.so

password   requisite pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password   sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password   sufficient pam_sss.so use_authtok
password   required pam_deny.so

session    optional pam_keyinit.so revoke
session    required pam_limits.so
session    optional pam_systemd.so
session    optional pam_oddjob_mkhomedir.so umask=0077
session    optional   pam_mkhomedir_plus.so skel=/dev/null umask=0077 homedir=/scratch
session    [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session    required pam_unix.so
session    optional pam_sss.so
```

If you dont wanty any skel files

```
session    optional   pam_mkhomedir_plus.so skel=/dev/null umask=0022 homedir=/scratch
```
