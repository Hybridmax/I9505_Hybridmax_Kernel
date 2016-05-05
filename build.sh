#!/bin/bash
# Kernel Build Script by Hybridmax (hybridmax95@gmail.com)

clear
echo
echo

#########################################################################################
# Set variables

export KERNEL_DIR=$(pwd)
export TOOLCHAIN_DIR=/home/hybridmax/android/toolchains/arm
export BUILD_THREADS=`grep processor /proc/cpuinfo|wc -l`
export KERNEL_DEFCONFIG=hybridmax-jf_defconfig
export DEVELOPER="Hybridmax"
export DEVICE="S4"
export VERSION_NUMBER="$(cat $KERNEL_DIR/version)"
export KERNELNAME="$DEVELOPER-$DEVICE-$VERSION_NUMBER"
export HYBRIDVER="-$KERNELNAME"

#########################################################################################
# Toolchains

#UBER
BCC=$TOOLCHAIN_DIR/uber-arm-eabi_5.3/bin/arm-eabi-

#########################################################################################
# Cleanup old files from build environment

CLEANUP()
{
	echo "Cleanup build environment...................."
	echo " "
	make clean
	make mrproper
	make distclean
	ccache -c
}

#########################################################################################
# Set build environment variables & compile

BUILD_KERNEL()
{
	echo "Set build variables.........................."
	echo " "
	export ARCH=arm
	export SUBARCH=arm
	export CCACHE=CCACHE
	export USE_CCACHE=1
	export USE_SEC_FIPS_MODE=true
	export KCONFIG_NOTIMESTAMP=true
	export CROSS_COMPILE=$BCC
	export ENABLE_GRAPHITE=true
	make $KERNEL_DEFCONFIG VARIANT_DEFCONFIG=jf_eur_defconfig SELINUX_DEFCONFIG=selinux_defconfig
	sed -i 's,CONFIG_LOCALVERSION="-Hybridmax",CONFIG_LOCALVERSION="'$HYBRIDVER'",' .config
	make -j$BUILD_THREADS
}

#########################################################################################
# Check if Image was compiled successful

IMAGE_CHECK()
{
if [ -f "arch/arm/boot/zImage" ]; then
	clear
	echo "............................................."
	echo "Done, Image compilation was successful!"
	echo "............................................."
	echo " "

else
	clear
	echo "............................................."
	echo "Image compilation Failed!"
	echo "Please check build.log!"
	echo "............................................."
	echo " "
fi
}

#########################################################################################
# Create Log File of Build

rm -rf ./build.log
(
	START_TIME=`date +%s`
	CLEANUP
	BUILD_KERNEL
	IMAGE_CHECK
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo " "
) 2>&1	 | tee -a ./build.log

exit 1
