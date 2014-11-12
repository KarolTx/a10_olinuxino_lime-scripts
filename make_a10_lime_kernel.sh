#!<bin/sh

KERNEL_DIR=/home/user/a10_lime_kernel
#FLAG=arm-none-eabi-
FLAG=arm-linux-gnueabihf-
KERNEL_CONF=/home/user/a10_lime_kernel.config

mkdir -p ${KERNEL_DIR}
cd ${KERNEL_DIR}

echo 'downloading uboot sources'
git clone -b sunxi https://github.com/linux-sunxi/u-boot-sunxi.git

echo 'downloading kernel sources'
git clone https://github.com/linux-sunxi/linux-sunxi

cd ${KERNEL_DIR}/u-boot-sunxi

echo 'compiling uboot'
make ARCH=arm CROSS_COMPILE=${FLAG} distclean
# a10-olinuxino-lime specific
make ARCH=arm CROSS_COMPILE=${FLAG} A10-OLinuXino-Lime_config
make ARCH=arm CROSS_COMPILE=${FLAG}

ls u-boot.bin u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin

cd ${KERNEL_DIR}/linux-sunxi

cp -f ${KERNEL_CONF} ${KERNEL_DIR}/linux-sunxi/arch/arm/configs/

echo 'configuring kernel'
# a10-olinuxino-lime specific
make ARCH=arm a10_lime_kernel.config

echo 'starting menuconfig'
make ARCH=arm menuconfig

echo 'compiling kernel'
make ARCH=arm CROSS_COMPILE=${FLAG} -j4 uImage

echo 'building modules'
make ARCH=arm CROSS_COMPILE=${FLAG} -j4 INSTALL_MOD_PATH=out modules
make ARCH=arm CROSS_COMPILE=${FLAG} -j4 INSTALL_MOD_PATH=out modules_install

