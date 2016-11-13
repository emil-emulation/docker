# create eaas-base 
# using: https://github.com/phusion/baseimage-docker

FROM phusion/baseimage:0.9.19
CMD ["/sbin/my_init"]
EXPOSE 80

## init bwfla repo
COPY files/bwfla.list /etc/apt/sources.list.d/bwfla.list
COPY files/pin-bwfla.pref /etc/apt/preferences.d/pin-bwfla.pref

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
bindfs \
hatari \
beebem \
kegs-sdl \
vice-sdl \
basilisk2 \
pce-atari-st \
pce-atari-st-data \
pce-dos \
pce-ibmpc \
pce-ibmpc-data \
pce-macplus \
pce-macplus-data \
pce-utils \
dosbox \
guacd \
libguac-client-sdlonp0 \
libsdl1.2debian \
qemu-utils \
qemu-system-x86 \
qemu-system-ppc \
sheepshaver \
libcurl3 \
libcurl3-gnutls \
qemu-block-extra \
xmount \
libxmount-input-qemu \
debconf-utils \
pmount \
mkisofs \
fuseiso \
dosfstools \
hfsutils \
apache2 \
nbd-server  

RUN sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

RUN rm -rf /usr/lib/xmount/libxmount_input_aff.so

## prepare the system to host sheepshaver
COPY files/init-scripts/ /etc/my_init.d/

# allow loop devices to be mounted by users
COPY files/pmount.allow /etc/pmount.allow

## prepare services
COPY files/service /etc/service/

## nbd config
COPY files/nbd-config /etc/nbd-server/config

#apache config
COPY files/apache-sites /etc/apache2/sites-available/
RUN a2ensite emil-ui && a2ensite emil-admin-ui && a2ensite emil-portable && a2enmod proxy_ajp

# copy tools and scripts
COPY files/binaries/ /usr/bin/


RUN useradd -ms /bin/bash bwfla && for grp in fuse disk audio plugdev kvm ; do adduser bwfla $grp; done

USER bwfla
#setup basic environment
RUN mkdir -p /home/bwfla/.bwFLA  \
/home/bwfla/classification-cache \
/home/bwfla/emil-environments    \
/home/bwfla/emil-object-environments    \
/home/bwfla/emil-admin-ui        \
/home/bwfla/emil-ui              \
/home/bwfla/emil-portable        \
/home/bwfla/image-archive        \
/home/bwfla/log                  \
/home/bwfla/objects              \
/home/bwfla/software-archive     

USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --force-yes
