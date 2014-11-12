scripts for creating kernel, uboot and FS image for a10-olinuxino-lime


prerequisites
-------------
* NO WARRANTY included
* Debian VM testing - nobody wants to mess up their main system and give root privileges to unknown script
* APT sources need links to stable, testing and emdebian repositories (deb http://www.emdebian.org/debian stable/testing main)
* packages;
  * binfmt-support
  * build-essential
  * dpkg-cross
  * gcc-4.7-arm-linux-gnueabihf
  * git
  * multistrap
  * ncurses-dev
  * qemu
  * qemu-user-static
  * u-boot-tools


settings
--------
* edit following variables at the beginning of the shell scripts
  * FS_DIR
  * FTP_MIRROR_COUNTRY
  * NEW_HOSTNAME
  * KERNEL_CONF
  * KERNEL_DIR
* grep for lines containing "FIXME" if one does not want default settings
* grep for "a10-olinuxino-lime specific" if one wants to change the board
* edit 1st-boot.sh for commands to be run after first boot


how to run
----------
1. edit settings
2. run make_arm_fs.sh
3. run make_a10_lime_kernel.sh
4. run prep_arm_img.sh
5. copy onto SD according to instructions from Olimex


default headless output
-----------------------
* uboot, kernel image and fs
* base packages without man pages, doc files (are not even installed)
* base network packages, vim, zips, screen, ... -> have a look at make_arm_fs.sh:208
* no locales
* iptables
* only one (getty) console running
* graphic modules turned OFF (can be turned on)
* no reserved graphic memory
* prepared 1st-boot.sh script to generate SSH keys on bootup
* dropbear but with working sftp (installed openssh-server, but turned off)


references
----------
* Olimex wiki page
* http://www.acmesystems.it/emdebian_grip

