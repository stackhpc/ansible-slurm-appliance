auth --enableshadow --passalgo=sha512
bootloader --location=mbr --append="crashkernel=auto rhgb quiet"
zerombr
text
firewall --disable
firstboot --disable
keyboard us
lang en_US
selinux --disabled
skipx
timezone UTC
install
network --bootproto=dhcp --onboot=on --hostname=Unnamed
reboot
url --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=BaseOS"
repo --name=AppStream --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=AppStream"
logging --level=info

# set passwd
rootpw --iscrypted $1$redhat$pRYx4oykDgtMyJUbXmnC2.

# partition code
clearpart --all --initlabel
part / --fstype="xfs" --size=1 --asprimary --grow

%packages --excludedocs --ignoremissing
authconfig
bash
bind-utils
coreutils
chkconfig
chrony
curl
dhclient
dmidecode
e2fsprogs
git
iputils
kbd
kernel
lsof
lvm2
man
openssh
passwd
policycoreutils
rootfiles
selinux-policy
smartmontools
strace
sudo
vim-enhanced
which
-cups-libs
-ed
-iscsi-initiator-utils
-kbd
-kudzu
-libX11
-prelink
-sendmail
-setserial
-smartmontools
-udftools
-xorg-x11-filesystem

%end #%packages

%post --log=/root/ks-post-install.log

# Harden sshd, permit root login
cat <<'EOF' >/etc/ssh/sshd_config
Protocol 2
SyslogFacility AUTHPRIV
#PermitRootLogin no
PermitRootLogin yes
#PasswordAuthentication no
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
UsePAM yes
X11Forwarding no
X11DisplayOffset 10
Subsystem sftp /usr/libexec/openssh/sftp-server

EOF

cat <<'EOF' >/etc/ssh/ssh_config
Host *
  ForwardAgent yes
  ForwardX11 yes
  GSSAPIAuthentication yes
  ForwardX11Trusted yes

EOF

%end #%post
