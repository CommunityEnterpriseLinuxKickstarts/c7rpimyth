#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts='us'
# Root password
rootpw --plaintext centos
# System language
lang en_US.UTF-8

# Use network installation
url --url=http://mirror.math.princeton.edu/pub/centos-altarch/7/os/armhfp/

# also use additional repos
repo --name="Updates" --baseurl=http://mirror.math.princeton.edu/pub/centos-altarch/7/updates/armhfp/ --cost=100
repo --name="Extras" --baseurl=http://mirror.math.princeton.edu/pub/centos-altarch/7/extras/armhfp/ --cost=100
repo --name="Kern" --baseurl=http://mirror.math.princeton.edu/pub/centos-altarch/7/kernel/armhfp/kernel-rpi2/ --cost=100
repo --name="epel" --baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/ --cost=100
repo --name="c7rpimyth" --baseurl=http://sourceforge.net/projects/c7rpimyth/files/yum/ --cost=100

# SELinux configuration
#selinux --permissive
selinux --disabled

# System services
services --enabled="NetworkManager"
# Firewall configuration
firewall --enabled --port=22:tcp
# Network information
network  --bootproto=dhcp --device=link --activate
xconfig --startxonboot
# Shutdown after installation
shutdown
# System timezone
timezone America/New_York
# System bootloader configuration
# configure extlinux bootloader
#bootloader extlinux
bootloader --location=boot
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part /boot --asprimary --fstype="ext4" --size=256 --label=boot
part / --asprimary --fstype="ext4" --size=3760 --label=rootfs

%pre

#End of Pre script for partitions
%end

%post


# Generating initrd
export kvr=$(rpm -q --queryformat '%{version}-%{release}' $(rpm -q raspberrypi2-kernel|tail -n 1))
dracut --force /boot/initramfs-$kvr.armv7hl.img $kvr.armv7hl


# Mandatory README file
cat >/root/README << EOF
== project userland ==

If you want to automatically resize your / partition, just type the following (as root user):
rootfs-expand

EOF

# Enabling chronyd on boot
#systemctl enable chronyd


# Specific cmdline.txt files needed for raspberrypi2/3
cat > /boot/cmdline.txt << EOF
console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait
EOF

# Setting correct yum variable to use raspberrypi kernel repo
echo "rpi2" > /etc/yum/vars/kvariant

# turn off gdm and turn on lightdm
systemctl --no-reload disable gdm.service 2> /dev/null || :
systemctl stop gdm.service  2> /dev/null || :
systemctl enable lightdm.service 2> /dev/null || :

#turn on zram memory swapper
systemctl enable zram-swap --now 2> /dev/null || :

#disable selinux/audit
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
systemctl --no-reload disable auditd.service  2> /dev/null || :

#set mythtv account to automyth specs
sed -i "s|mythbackend user:/var/lib/mythtv:/sbin/nologin|mythtv:/home/mythtv:/bin/bash|" /etc/passwd
cat >> /etc/sudoers << FOE-SUDOERS
%mythtv ALL=(ALL)       NOPASSWD: ALL
FOE-SUDOERS

#add mythtv account to wheel for sudo
/usr/sbin/usermod -aG wheel mythtv
sed -i "s|.*# %wheel|%wheel|" /etc/sudoers

#set mythtv passwd to mythtv
echo mythtv:mythtv|chpasswd 2> /dev/null || :
# set up lightdm autologin

sed -i 's/^#autologin-user=.*/autologin-user=mythtv/' /etc/lightdm/lightdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
#sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

# set default lightdm session, otherwise login will fail
sed -i 's/^#user-session=.*/user-session=lxqt/' /etc/lightdm/lightdm.conf

# set chromium browsers home and startpages 
#sed -i 's|"https://start.fedoraproject.org"|"http://localhost/ReadMe.txt"|' /etc/chromium/master_preferences
#sed -i 's|"http://tools.google.com/chrome/intl/en/welcome.html"|"http://localhost/phpMyAdmin"|g' /etc/chromium/master_preferences

# create the mythtv directory for the account and  make sure to set the right permissions and selinux contexts
mkdir -v /home/mythtv
mkdir -v /mythtv
chown -Rv mythtv. /home/mythtv/
chown -Rv mythtv. /mythtv/
/sbin/restorecon -R /home/mythtv/
/sbin/restorecon -R /mythtv


#add entries for these to their respective rpms as patches or inline to rpm
cat > /etc/sysconfig/desktop << EOF
PREFERRED=/usr/bin/lxqt-session
DISPLAYMANAGER=/usr/sbin/lightdm

EOF

#TODO: xfce selection option on first account login is annoying, import a config for the mythtv account and then set up a skel for new accts to get the default one
#add repo setup for epel
cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Epel rebuild for armhfp
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/
enabled=1
gpgcheck=0

EOF



#reduce srams default from 1/2  memory max to 1/3
sed -i 's/FACTOR=2/FACTOR=3/' /etc/zram.conf

#todo add raspi-config? limited or full?
#add a default config.txt , uncomment the last section stanzas marked with ## to overclock a pi2 to 1000mhz
cat > /boot/config.txt << EOF

# For more options and information see
# http://rpf.io/configtxt
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
#hdmi_safe=1

# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
#disable_overscan=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
#overscan_left=16
#overscan_right=16
#overscan_top=16
#overscan_bottom=16

# uncomment to force a console size. By default it will be display's size minus
# overscan.
#framebuffer_width=1280
#framebuffer_height=720

# uncomment if hdmi display is not detected and composite is being output
#hdmi_force_hotplug=1

# uncomment to force a specific HDMI mode (this will force VGA)
#hdmi_group=1
#hdmi_mode=1

# uncomment to force a HDMI mode rather than DVI. This can make audio work in
# DMT (computer monitor) modes
#hdmi_drive=2

# uncomment to increase signal to HDMI, if you have interference, blanking, or
# no display
#config_hdmi_boost=4

# uncomment for composite PAL
#sdtv_mode=2

#uncomment to overclock the arm. 700 MHz is the default.
##arm_freq=1000

# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Uncomment this to enable the lirc-rpi module
#dtoverlay=lirc-rpi

# Additional overlays and parameters are documented /boot/overlays/README

# Enable audio (loads snd_bcm2835)
dtparam=audio=on
gpu_mem=320
##core_freq=500
##sdram_freq=500
##over_voltage=2

EOF







# RaspberryPi 3 config for wifi
cat > /usr/lib/firmware/brcm/brcmfmac43430-sdio.txt << EOF
# NVRAM file for BCM943430WLPTH
# 2.4 GHz, 20 MHz BW mode

# The following parameter values are just placeholders, need to be updated.
manfid=0x2d0
prodid=0x0727
vendid=0x14e4
devid=0x43e2
boardtype=0x0727
boardrev=0x1101
boardnum=22
#macaddr=00:90:4c:c5:12:38
sromrev=11
boardflags=0x00404201
boardflags3=0x08000000
xtalfreq=37400
nocrc=1
ag0=255
aa2g=1
ccode=ALL

pa0itssit=0x20
extpagain2g=0
#PA parameters for 2.4GHz, measured at CHIP OUTPUT
pa2ga0=-168,7161,-820
AvVmid_c0=0x0,0xc8
cckpwroffset0=5

# PPR params
maxp2ga0=84
txpwrbckof=6
cckbw202gpo=0
legofdmbw202gpo=0x66111111
mcsbw202gpo=0x77711111
propbw202gpo=0xdd

# OFDM IIR :
ofdmdigfilttype=18
ofdmdigfilttypebe=18
# PAPD mode:
papdmode=1
papdvalidtest=1
pacalidx2g=42
papdepsoffset=-22
papdendidx=58

# LTECX flags
ltecxmux=0
ltecxpadnum=0x0102
ltecxfnsel=0x44
ltecxgcigpio=0x01

il0macaddr=00:90:4c:c5:12:38
wl0id=0x431b

deadman_to=0xffffffff
# muxenab: 0x1 for UART enable, 0x2 for GPIOs, 0x8 for JTAG
muxenab=0x1
# CLDO PWM voltage settings - 0x4 - 1.1 volt
#cldo_pwm=0x4

#VCO freq 326.4MHz
spurconfig=0x3 

edonthd20l=-75
edoffthd20ul=-80

EOF

# RaspberryPI 3 model+ wifi
cat > /usr/lib/firmware/brcm/brcmfmac43455-sdio.txt << EOF
# Cloned from bcm94345wlpagb_p2xx.txt 
NVRAMRev=$Rev: 498373 $
sromrev=11
vendid=0x14e4
devid=0x43ab
manfid=0x2d0
prodid=0x06e4
#macaddr=00:90:4c:c5:12:38
nocrc=1
boardtype=0x6e4
boardrev=0x1304

#XTAL 37.4MHz
xtalfreq=37400

btc_mode=1
#------------------------------------------------------
#boardflags: 5GHz eTR switch by default
#            2.4GHz eTR switch by default
#            bit1 for btcoex
boardflags=0x00480201
boardflags2=0x40800000
boardflags3=0x48200100
phycal_tempdelta=15
rxchain=1
txchain=1
aa2g=1
aa5g=1
tssipos5g=1
tssipos2g=1
femctrl=0
AvVmid_c0=1,165,2,100,2,100,2,100,2,100
pa2ga0=-129,6525,-718
pa2ga1=-149,4408,-601
pa5ga0=-185,6836,-815,-186,6838,-815,-184,6859,-815,-184,6882,-818
pa5ga1=-202,4285,-574,-201,4312,-578,-196,4391,-586,-201,4294,-575
itrsw=1
pdoffsetcckma0=2
pdoffset2gperchan=0,-2,1,0,1,0,1,1,1,0,0,-1,-1,0
pdoffset2g40ma0=16
pdoffset40ma0=0x8888
pdoffset80ma0=0x8888
extpagain5g=2
extpagain2g=2
tworangetssi2g=1
tworangetssi5g=1
# LTECX flags
# WCI2
ltecxmux=0
ltecxpadnum=0x0504
ltecxfnsel=0x22
ltecxgcigpio=0x32

maxp2ga0=80
ofdmlrbw202gpo=0x0022
dot11agofdmhrbw202gpo=0x4442
mcsbw202gpo=0x98444422
mcsbw402gpo=0x98444422
maxp5ga0=82,82,82,82
mcsbw205glpo=0xb9555000
mcsbw205gmpo=0xb9555000
mcsbw205ghpo=0xb9555000
mcsbw405glpo=0xb9555000
mcsbw405gmpo=0xb9555000
mcsbw405ghpo=0xb9555000
mcsbw805glpo=0xb9555000
mcsbw805gmpo=0xb9555000
mcsbw805ghpo=0xb9555000

swctrlmap_2g=0x00000000,0x00000000,0x00000000,0x010000,0x3ff
swctrlmap_5g=0x00100010,0x00200020,0x00200020,0x010000,0x3fe
swctrlmapext_5g=0x00000000,0x00000000,0x00000000,0x000000,0x3
swctrlmapext_2g=0x00000000,0x00000000,0x00000000,0x000000,0x3

vcodivmode=1
deadman_to=481500000

ed_thresh2g=-54
ed_thresh5g=-54
eu_edthresh2g=-54
eu_edthresh5g=-54
ldo1=4
rawtempsense=0x1ff
cckPwrIdxCorr=3
cckTssiDelay=150
ofdmTssiDelay=150
txpwr2gAdcScale=1
txpwr5gAdcScale=1
dot11b_opts=0x3aa85
cbfilttype=1
fdsslevel_ch11=6

EOF


# Remove ifcfg-link on pre generated images
#rm -f /etc/sysconfig/network-scripts/ifcfg-link

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end

%packages
@core
@x11
lxqt-about
lxqt-globalkeys
lxqt-notificationd
lxqt-openssh-askpass
lxqt-session
lxqt-panel
lxqt-policykit
lxqt-powermanagement
lxqt-qtplugin
lxqt-runner
lxqt-wallet
lximage-qt
lxqt-config
lxqt-sudo
lxqt-build-tools
openbox
qterminal
qterminal-qt5
pcmanfm-qt

lightdm

#zram swapper
zram

xorg-x11-server-Xorg
xorg-x11-fonts-Type1

network-manager-applet
NetworkManager-bluetooth

chrony
cloud-utils-growpart
bridge-utils

net-tools
raspberrypi-vc-utils
raspberrypi2-firmware
raspberrypi2-kernel
uboot-images-armv7

#for livemedia-creator dev
yum-langpacks

hostapd
dhcp-common
mariadb
mariadb-server
ntp
httpd


#todo
#pnmixer?
#mythtv-streamzap-config
#amscripts

alsa-plugins-oss
alsa-plugins-pulseaudio
pulseaudio-module-bluetooth
pavucontrol
blueberry
brasero
cheese
evince
filezilla
firefox
git

gparted

htop

lirc-compat
lirc-config
lirc-core
lirc-disable-kernel-rc
lirc-doc
lirc-drv-ftdi
lirc-tools-gui

lynx
ntfsprogs
ntfs-3g
psmisc
screen
tmux
tigervnc
nmap
v4l-utils
vim
wget
wodim
xarchiver

hdhomerun
omxplayer
xvidcore
x264
mythtv-frontend
mythtv-backend
mythtv-docs
mythgallery
mythmusic
mythzoneminder
mythffmpeg
mythweb
#mytharchive #needs ffmpeg

-caribou*
-gnome-shell-browser-plugin
-java-1.6.0-*
-java-1.7.0-*
-java-11-*
-python*-caribou*

%end
