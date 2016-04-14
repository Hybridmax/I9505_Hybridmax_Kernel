* Get GT-I9505_EUR open source code
    : GT-I9505_EUR_LL_Opensource.zip, version : I9505XXUHOH2
    ( Download site : http://opensource.samsung.com )
     Unzip it, then you will see the file Kernel.tar.gz which includes the kernel source code.

* Unzip Kernel.zip and overwrite to the kernel source code.

################################################################################
HOW TO BUILD KERNEL FOR GT-I9505_EUR_LL_XX

1. How to Build
	- get Toolchain
	download and install arm-eabi-4.7 toolchain for ARM EABI.
	Extract kernel source and move into the top directory.

	$ ./build_kernel

	
2. Output files
	- Kernel : Kernel/arch/arm/boot/zImage
	- module : Kernel/drivers/*/*.ko
	
3. How to Clean	
    $ make clean
	
4. How to make .tar binary for downloading into target.
	- change current directory to Kernel/arch/arm/boot
	- type following command
	$ tar cvf GT-I9505_EUR_LL_XX.tar zImage
#################################################################################