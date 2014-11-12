#!/bin/sh


KERNEL_DIR=/home/user/a10_lime_kernel
FS_DIR=/home/user/arm
SCRIPT_BIN=/home/user/script.bin
FINAL_DIR=/home/user/arm_fs

echo 'copying files to /boot'
# a10-olinuxino-lime specific
cp -f ${SCRIPT_BIN} ${FS_DIR}/boot/script.bin
cp -f ${KERNEL_DIR}/linux-sunxi/arch/arm/boot/uImage ${FS_DIR}/boot/uImage
cp -f ${KERNEL_DIR}/u-boot-sunxi/u-boot-sunxi-with-spl.bin ${FS_DIR}/boot/u-boot-sunxi-with-spl.bin

echo 'write u-boot-sunxi-with-spl.bin'
echo "dd if=${FS_DIR}/boot/u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8"

echo 'copying modules to /lib'
rm -rf  ${FS_DIR}/lib/modules/
cp -rf ${KERNEL_DIR}/linux-sunxi/out/lib/modules ${FS_DIR}/lib/
rm -rf ${FS_DIR}/lib/firmware
cp -rf ${KERNEL_DIR}/linux-sunxi/out/lib/firmware ${FS_DIR}/lib/

# FIXME change
# a10-olinuxino-lime specific
echo 'setting uEnv.txt'
cat > ${FS_DIR}/boot/uEnv.txt <<EOF
bootargs=console ttyS0,115200 root=/dev/mmcblk0p2 rootwait sunxi_fb_mem_reserve=8 loglevel=8 panic=10
extraargs=sunxi_no_mali_mem_reserve sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_fb_mem_reserve=8
EOF

echo 'making a copy of the final FS'
mkdir -p ${FINAL_DIR}
rsync -axHAX --progress ${PREP_DIR} ${FINAL_DIR}

