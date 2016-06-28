#!/bin/sh
set -e
 . /scripts/functions
set +e

has_param()
{
  param=$1
  set +e
  grep -q -o "${param}\S*" /proc/cmdline
  rc=$?
  set -e
  return "${rc}"
}

get_param()
{
  param_name=$1
  param_id=$(grep -o "${param_name}=\S*" /proc/cmdline)
  echo "${param_id#${param_name}=}"
}

up_device()
{
  device=$1
  ifconfig $device up
  dhclient -4 -v -1 $device
  kill $(cat /var/run/dhclient.pid)
}

up_boot_device()
{
  bootif_mac=$(get_param BOOTIF)

  ls /sys/class/net
  for device in /sys/class/net/*; do
    if [ -f "$device/address" ]; then
      current_mac=$(cat "$device/address")

      if [ "$bootif_mac" = "$current_mac" ];then
        DEVICE=${device##*/}
        up_device $DEVICE
        break
      fi
    fi
  done
}

up_all_interfaces()
{
  for device in /sys/class/net/*; do
    DEVICE=${device##*/}
    up_device $DEVICE
  done
}

prepare()
{
  # Ensure all our net modules get loaded so we can actually compare MAC addresses.
  udevadm trigger
  udevadm settle

  # Create some files and directories dhclient-script expects
  mkdir -p /var/lib/dhcp/
  mkdir -p /var/run
  mkdir -p /etc
  touch /etc/fstab

  # Splat all busybox apps out onto the FS with symblinks
  # Needed for dhclient to use them from a bash context
  busybox --list | while read app; do
    busybox ln -sf /bin/busybox /sbin/$app
  done

  # Block ipconfig from running
  cp /sbin/true /bin/ipconfig

}

start_networking()
{
  prepare

  if has_param BOOTIF; then
    up_boot_device
  else
    up_all_interfaces
  fi
}

if has_param DEBUG; then
  set -x
fi

start_networking
