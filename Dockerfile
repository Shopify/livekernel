FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

# Divert initctl temporarily so apt-update can work
RUN dpkg-divert --local --rename --add /sbin/initctl

# Don't invoke rc.d policy scripts
ADD util/rc.d-policy-stub /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

################ start Install packages ###################
# Do an initial update so we have updated lists for the build
RUN apt-get update

RUN apt-get install -y --force-yes linux-generic-lts-vivid live-boot
RUN apt-get install -y --force-yes isc-dhcp-client

ADD util/conf_net.sh /etc/initramfs-tools/scripts/init-premount/
RUN chmod +x /etc/initramfs-tools/scripts/init-premount/conf_net.sh

ADD util/add_dhclient.sh /etc/initramfs-tools/hooks
RUN chmod +x /etc/initramfs-tools/hooks/add_dhclient.sh

# Backport xenial's liveboot scripts for proper overlayfs support
RUN rm -rf /lib/live/boot/*
ADD util/boot.tar.gz /lib/live/boot
ADD util/hooks/live /usr/share/initramfs-tools/hooks/
ADD util/scripts/live /usr/share/initramfs-tools/scripts/
ADD util/live-boot /bin

RUN update-initramfs -u

###########################################################

# Undo the fake policy-rc.d
RUN rm /usr/sbin/policy-rc.d

ENTRYPOINT ["sleep"]
CMD ["infinity"]
