#!/bin/bash
# Kernel Repack Script by Hybridmax (hybridmax95@gmail.com)

clear
echo
echo

# vars
export KERNEL_DIR=$(pwd)
export CURDATE=`date "+%Y.%m.%d"`
export zIMAGE_DIR=arch/arm/boot
export BUILD_IMG=build_image
export ZIP_DIR=zip_files
export MODULES_DIR=build_image/zip_files/system/lib/modules
export DEVELOPER="Hybridmax"
export DEVICE="S4"
export VERSION_NUMBER="$(cat $KERNEL_DIR/version)"
export HYBRIDVER="$DEVELOPER-Kernel-$DEVICE-$VERSION_NUMBER-($CURDATE)"
export KERNEL_NAME="$HYBRIDVER"

#########################################################################################
# Copy Modules & Image

echo "Copy Modules............................"
echo " "
find -name '*.ko' -exec cp -av {} $MODULES_DIR \;
#${CROSS_COMPILE}strip --strip-unneeded $MODULES_DIR/*

echo "Copy Image.............................."
echo " "
cp $zIMAGE_DIR/zImage $BUILD_IMG/I9505/zImage
#########################################################################################
# Ramdisk Generation

echo "Make Ramdisk............................"
echo " "
cd $BUILD_IMG
mkdir -p ramfs_tmp
cp -a I9505/ramdisk/* ramfs_tmp
cp ramdisk_fix_permissions.sh ramfs_tmp/ramdisk_fix_permissions.sh
chmod 0777 ramfs_tmp/ramdisk_fix_permissions.sh
cd ramfs_tmp
./ramdisk_fix_permissions.sh
rm -f ramdisk_fix_permissions.sh

find . | fakeroot cpio -H newc -o | gzip -9 > ../ramdisk.cpio.gz

cd ..

mv ramdisk.cpio.gz I9505

rm -r ramfs_tmp

#########################################################################################
# Boot.img Generation

echo "Make boot.img..........................."
echo " "
cd I9505
./../mkbootimg --kernel zImage --ramdisk ramdisk.cpio.gz --base 0x80200000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x02000000 --tags_offset 0x00000100 --cmdline 'console=null androidboot.hardware=qcom user_debug=23 msm_rtb.filter=0x3F ehci-hcd.park=3' -o boot.img
echo -n "SEANDROIDENFORCE" >> boot.img
# copy the final boot.img to output directory ready for zipping
cp boot.img ../$ZIP_DIR/boot.img

#########################################################################################
# Generate Odin Flashable Kernel

#echo "Make tar.md5..........................."
#echo " "
#tar -H ustar -cvf $KERNEL_NAME.tar boot.img
#md5sum -t $KERNEL_NAME.tar >> $KERNEL_NAME.tar
#mv $KERNEL_NAME.tar output_kernel

#########################################################################################
# ZIP Generation

echo "Make ZIP................................"
echo " "
cd ../$ZIP_DIR
zip -r $KERNEL_NAME.zip *
mv $KERNEL_NAME.zip ../output_kernel

#########################################################################################
# Cleaning Up

cd ../..
echo "Make Clean.............................."
echo " "
rm -rf $BUILD_IMG/I9505/zImage
rm -rf $BUILD_IMG/I9505/kernel
rm -rf $BUILD_IMG/I9505/ramdisk.cpio.*
rm -rf $BUILD_IMG/I9505/boot.img
rm -rf $BUILD_IMG/boot.img
rm -rf $BUILD_IMG/ramdisk-cpio.*
rm -rf $BUILD_IMG/zip_files/boot.img
rm -rf $BUILD_IMG/zip_files/hybridmax/boot.img
rm -rf $BUILD_IMG/zip_files/system/lib/modules/*
echo "Done, $KERNEL_NAME.zip is ready!"
echo " "
