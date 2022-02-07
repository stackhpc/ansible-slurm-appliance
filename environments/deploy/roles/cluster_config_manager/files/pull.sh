#!/bin/bash
# Pull Script

copy_path="${1%/}"
timestamp=$(/bin/date +'%m%d%Y_%s')

if [ $(/bin/uname -n| /bin/egrep -v '(r[1-9]lead|admin|esac|emg|el|ed)' | /bin/wc -c) -lt 2 ]; then
  echo 'Only run on compute nodes, nothing else!'
  exit 1
fi

if [ $(echo ${copy_path}|wc -c) -lt 3 ]; then
   echo "Requires argument for pull path"
   echo "Usage: pull.sh /nopt/nrel/admin/cluster_config_manager/commit_etc/compute/"
   exit 1
fi

/usr/bin/cmp "${copy_path}/passwd" /etc/passwd
passwd_cmp=$?
/usr/bin/cmp "${copy_path}/shadow" /etc/shadow
shadow_cmp=$?
/usr/bin/cmp "${copy_path}/group" /etc/group
group_cmp=$?

# Just exit if no changes were made to file
if [ $passwd_cmp -eq 0 ] && [ $shadow_cmp -eq 0 ] && [ $group_cmp -eq 0 ]; then
  echo "Nothing Changed"
  exit 0
fi

if [ $(/bin/wc -l "${copy_path}/passwd"|awk '{print $1}') -lt 50 ] ||\
   [ $(/bin/wc -l "${copy_path}/shadow"|awk '{print $1}') -lt 50 ] ||\
   [ $(/bin/wc -l "${copy_path}/group"|awk '{print $1}') -lt 50 ]; then
  echo "Config files do not meet quality check"
  exit 1
fi

/bin/cp "${copy_path}/passwd" /etc/passwd_$timestamp
/bin/cp "${copy_path}/shadow" /etc/shadow_$timestamp
/bin/cp "${copy_path}/group" /etc/group_$timestamp

/bin/chmod 0644 /etc/passwd_$timestamp
/bin/chmod 0000 /etc/shadow_$timestamp
/bin/chmod 0644 /etc/group_$timestamp

/bin/mv /etc/passwd_$timestamp /etc/passwd
/bin/mv /etc/shadow_$timestamp /etc/shadow
/bin/mv /etc/group_$timestamp /etc/group

echo "Updated config files"
exit 0
