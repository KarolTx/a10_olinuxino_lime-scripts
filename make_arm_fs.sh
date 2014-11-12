#!/bin/sh

# FIXME change
PREP_DIR=/home/user/arm
FTP_MIRROR_COUNTRY=de
FIRST_BOOT_SH=/home/user/1st-boot.sh

NEW_HOSTNAME=a10-olinuxino-lime
NEW_USER=

QEMU_BIN=/usr/bin/qemu-arm-static
MULTISTRAP_CONF=/tmp/multistrap.conf.$$
INITTAB=/tmp/inittab.$$
PACKAGES_LIST=/tmp/packages.list.$$


cat > ${MULTISTRAP_CONF} <<EOF
[General]
# arch and directory can be specified on the command line.
arch=armhf
directory=${PREP_DIR}

# same as --tidy-up option if set to true
cleanup=true

# retain the sources outside the rootfs for distribution
# specify a directory to which all the .debs can be moved.
# or override with the --source-dir option.
retainsources=

# same as --no-auth option if set to true
# keyring packages listed in each debootstrap will
# still be installed.
noauth=true

# retries not needed.
#retries=5

# extract all downloaded archives
unpack=true

# the order of sections is no longer important.
# debootstrap determines which repository is used to
# calculate the list of Priority: required packages
bootstrap=Updates Debian

# the order of sections is no longer important.
# aptsources is a list of sections to be listed
# in the /etc/apt/sources.list.d/multistrap.sources.list
# of the target.
aptsources=Updates Debian

[Updates]
packages=apt
source=http://ftp.${FTP_MIRROR_COUNTRY}.debian.org/debian
keyring=debian-archive-keyring
suite=wheezy-proposed-updates

[Debian]
packages=
source=http://ftp.${FTP_MIRROR_COUNTRY}.debian.org/debian
keyring=debian-archive-keyring
suite=wheezy
EOF

echo 'creating base file structure'
mkdir -p ${PREP_DIR}
multistrap -f ${MULTISTRAP_CONF}
rm -f ${MULTISTRAP_CONF}

echo 'preping chroot'
cp -f ${QEMU_BIN} ${PREP_DIR}/usr/bin/

echo 'runing package configuration'
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} dpkg --configure -a

echo 'setting /etc/fstab'
cat > ${PREP_DIR}/etc/fstab <<EOF
# /etc/fstab: static file system information.
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/root   /       ext4    noatime,commit=120,errors=remount-ro    0 1
tmpfs   /run/shm    tmpfs   defaults    0 0
tmpfs   /tmp        tmpfs   defaults    0 0
tmpfs   /var/tmp    tmpfs   defaults    0 0
cgroup  /sys/fs/cgroup  cgroup  defaults    0 0
EOF

echo 'setting /etc/hostname'
cat > ${PREP_DIR}/etc/hostname <<EOF
${NEW_HOSTNAME}
EOF

# FIXME change
echo 'setting /etc/hosts'
cat > ${PREP_DIR}/etc/hosts <<EOF
127.0.0.1   localhost
127.0.0.1   ${NEW_HOSTNAME}
EOF

# FIXME change
echo 'setting network interfaces'
cat > ${PREP_DIR}/etc/network/interfaces <<EOF
auto lo eth0 wlan0
allow-hotplug eth0

# loopback
iface lo inet loopback

# ethernet
#iface eth0 inet dhcp
# or static
iface eth0 inet static
    address 192.168.0.7
    netmask 255.255.255.0

# wlan
#iface wlan0 inet dhcp
#    wpa-ssid SSID
#    wpa-psk SECRET
EOF

# FIXME change
#cat > ${PREP_DIR}/etc/resolv.conf <<EOF
#nameserver 1.2.3.4
#EOF
cp -f /etc/resolv.conf ${PREP_DIR}/etc/resolv.conf

# FIXME change
# a10-olinuxino-lime specific
echo 'setting /etc/enviroment'
cat > ${PREP_DIR}/etc/enviroment <<EOF
VDPAU_DRIVER=sunxi
EOF
#LC_ALL="en_US.utf8"
#TSLIB_TSEVENTTYPE=raw
#TSLIB_CONSOLEDEVICE=none
#TSLIB_FBDEVICE=/dev/fb0
#TSLIB_TSDEVICE=/dev/input/event0
#TSLIB_CALIBFILE=/etc/pointercal
#TSLIB_CONFFILE=/usr/etc/ts.conf
#TSLIB_PLUGINDIR=/usr/lib/ts

# FIXME change
# a10-olinuxino-lime specific
echo 'setting /etc/modules'
cat > ${PREP_DIR}/etc/modules <<EOF
# SATA
sw_ahci_platform

# display and GPU
#lcd
#hdmi
#mali
#mali_drm
#ump
#disp
#sunxi_cedar_mod

# wifi
#8192cu

# GPIO
gpio-sunxi
leds-sunxi
ledtrig-heartbeat

# flash
nand
EOF

echo 'modifying /etc/inittab'
sed -r 's/^([2-6]:)/#\1/' < ${PREP_DIR}/etc/inittab > ${INITTAB}
mv -f ${INITTAB} ${PREP_DIR}/etc/inittab

echo 'preparing 1st-boot-up script'
cp -f ${FIRST_BOOT_SH} ${PREP_DIR}/etc/init.d/1st-boot.sh
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} insserv -d 1st-boot.sh

echo 'setting dpkg hooks'
cat > ${PREP_DIR}/etc/dpkg/dpkg.cfg.d/01-smalldisk <<EOF
# block documentation
path-exclude /usr/share/doc/*
# keep copyright files for legal reasons
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
# lintian stuff is small, but really unnecessary
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
# block non-us locales
path-exclude /usr/share/locale/*
path-include /usr/share/locale/en*
EOF

echo 'setting APT sources'
cat > ${PREP_DIR}/etc/apt/sources.list <<EOF
deb http://ftp.${FTP_MIRROR_COUNTRY}.debian.org/debian/ wheezy main contrib non-free
deb http://ftp.${FTP_MIRROR_COUNTRY}.debian.org/debian/ wheezy-updates main contrib non-free
#deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://ftp.${FTP_MIRROR_COUNTRY}.debian.org/debian/ wheezy-backports main contrib non-free
EOF

echo 'updating package list'
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} apt-get update --assume-yes

# FIXME change
echo 'installing selected packages'
cat > ${PACKAGES_LIST} <<EOF
at
cron
fake-hwclock
sudo

coreutils
diffutils
file
gawk
grep
mc
less
sed
screen

bzip2
gzip
tar
unrar
unzip
zip

dropbear
isc-dhcp-client
ifupdown
iproute
iptables
ntp
openssh-server
wpasupplicant

i2c-tools
rsync

vim
EOF

LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} apt-get install --no-install-recommends --assume-yes $(cat ${PACKAGES_LIST})
rm -f ${PACKAGES_LIST}

echo 'stoping scheduler deamons'
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} /etc/init.d/cron stop
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} /etc/init.d/atd stop

echo 'upgrading packages'
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} apt-get dist-upgrade --no-install-recommends --assume-yes
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} apt-get clean --assume-yes

echo 'set root password'
LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} passwd root

if [ ! -z "${NEW_USER}" ]
then
    echo 'adding new user'
    LC_ALL=C LANGUAGE=C LANG=C chroot ${PREP_DIR} adduser ${NEW_USER}
fi

echo 'cleaning chroot'
rm -f ${PREP_DIR}/usr/bin/qemu-arm-static

