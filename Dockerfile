FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

# Divert initctl temporarily so apt-update can work
RUN dpkg-divert --local --rename --add /sbin/initctl

# Don't invoke rc.d policy scripts
ADD util/rc.d-policy-stub /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

################ start Install packages ###################
# Do an initial update so we have updated lists for the build
RUN apt-get update

RUN apt-get install -y --force-yes linux-generic-lts-xenial live-boot
RUN apt-get install -y --force-yes isc-dhcp-client

ADD util/conf_net.sh /etc/initramfs-tools/scripts/init-premount/
RUN chmod +x /etc/initramfs-tools/scripts/init-premount/conf_net.sh

ADD util/add_dhclient.sh /etc/initramfs-tools/hooks
RUN chmod +x /etc/initramfs-tools/hooks/add_dhclient.sh

RUN update-initramfs -u

###########################################################

# Undo the diversion so upstart can work
RUN rm /sbin/initctl
RUN dpkg-divert --local --rename --remove /sbin/initctl

# Undo the fake policy-rc.d
RUN rm /usr/sbin/policy-rc.d

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
# this forces "apt-get update" in dependent images, which is also good

CMD ['/bin/sleep infinity']
