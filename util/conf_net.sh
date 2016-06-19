#!/bin/sh

set -x
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
  dhclient -4 -v -1 $device
  dhclient -x
}

up_boot_device()
{
  temp_mac=$(get_param BOOTIF)

  # convert to typical mac address format by replacing "-" with ":"
  bootif_mac=""
  IFS='-'
  for x in $temp_mac ; do
    if [ -z "$bootif_mac" ]; then
      bootif_mac="$x"
    else
      bootif_mac="$bootif_mac:$x"
    fi
  done
  unset IFS

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

start_networking()
{
  if has_param BOOTIF; then
    up_boot_device
  else
    up_all_interfaces
  fi
}


start_networking
