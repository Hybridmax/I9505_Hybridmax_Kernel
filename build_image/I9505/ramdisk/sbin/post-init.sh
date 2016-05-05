#!/system/bin/sh

BB=/system/xbin/busybox
PROFILE_PATH=/data/.hybridmax

# Mounting partition in RW mode

OPEN_RW()
{
        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;
}
OPEN_RW;

# Installing Busybox
$BB chmod 06755 /system/xbin/busybox
/system/xbin/busybox --install -s /system/xbin/

# Fixing ROOT
/system/xbin/daemonsu --auto-daemon &

sleep 1;

OPEN_RW;

# Fix init.d folder permissions
$BB chown -R root.root /system/etc/init.d
$BB chmod -R 755 /system/etc/init.d
$BB chmod 755 /system/etc/init.d/*

# Start script in init.d folder
$BB run-parts /system/etc/init.d/

# Symlink
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
fi;

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod 06755 /sbin/busybox;
	$BB chmod 06755 /system/xbin/busybox;
}
CRITICAL_PERM_FIX;

# Prop tweaks
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop pm.sleep_mode 1
setprop logcat.live disable
setprop profiler.force_disable_ulog 1
setprop ro.ril.disable.power.collapse 0
setprop persist.service.btui.use_aptx 1

# Make sure that max gpu clock is set by default to 450 MHz
$BB echo 450000000 > /sys/class/kgsl/kgsl-3d0/max_gpuclk;

# STweaks support
$BB rm -f /system/app/HybridTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/Hulk-Kernel sTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks_Googy-Max.apk > /dev/null 2>&1;
$BB rm -f /system/app/GTweaks.apk > /dev/null 2>&1;
$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
$BB chown root.root /system/priv-app/STweaks.apk;
$BB chmod 644 /system/priv-app/STweaks.apk;

if [ ! -d /data/.hybridmax ]; then
	$BB mkdir -p /data/.hybridmax;
fi;

$BB chmod -R 0777 /data/.hybridmax/;

. /res/customconfig/customconfig-helper;

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.hybridmax/.ccxmlsum`" ];
then
   $BB rm -f /data/.hybridmax/*.profile;
   $BB echo ${ccxmlsum} > /data/.hybridmax/.ccxmlsum;
fi;

[ ! -f /data/.hybridmax/default.profile ] && cp /res/customconfig/default.profile /data/.hybridmax/default.profile;
[ ! -f /data/.hybridmax/battery.profile ] && cp /res/customconfig/battery.profile /data/.hybridmax/battery.profile;
[ ! -f /data/.hybridmax/balanced.profile ] && cp /res/customconfig/balanced.profile /data/.hybridmax/balanced.profile;
[ ! -f /data/.hybridmax/performance.profile ] && cp /res/customconfig/performance.profile /data/.hybridmax/performance.profile;

chmod -R 0777 /data/.hybridmax/;
chmod 777 $PROFILE_PATH/default.profile

read_defaults;
read_config;

# Android logger
if [ "$logger_mode" == "on" ]; then
	$BB echo "1" > /sys/kernel/logger_mode/logger_mode;
else
	$BB echo "0" > /sys/kernel/logger_mode/logger_mode;
fi;

# Scheduler
	$BB echo "$int_scheduler" > /sys/block/mmcblk0/queue/scheduler;
	$BB echo "$int_read_ahead_kb" > /sys/block/mmcblk0/bdi/read_ahead_kb;
	$BB echo "$ext_scheduler" > /sys/block/mmcblk1/queue/scheduler;
	$BB echo "$ext_read_ahead_kb" > /sys/block/mmcblk1/bdi/read_ahead_kb;

# CPU
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq;

# Apply STweaks defaults
export CONFIG_BOOTING=1
/res/uci.sh apply
export CONFIG_BOOTING=

OPEN_RW;

$BB chmod 777 $PROFILE_PATH/default.profile

# Fix critical perms again
	CRITICAL_PERM_FIX;
	
sleep 1;

# script finish here, so let me know when
rm /data/.hybridmax/Kernel-Test.log
touch /data/.hybridmax/Kernel-Test.log
echo "Kernel Tuning Script succesfully applied!" > /data/.hybridmax/Kernel-Test.log;

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system

