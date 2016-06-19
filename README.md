# Live kernel

This builds a live kernel for use in PXE booting a live image (such as livesys).

This is a thin wrapper around debian live-boot using an ubuntu kernel.

- live-boot from xenial has been backported to trusty
- dhclient is used instead of ipconfig, because ipconfig shits the bed a lot
- numerous dhclient-script dependencies have been ported in as well

To build:

```
./build.sh
```

To extract the live kernel and initramfs:

```
./extract.sh
```
