# c7rpimyth
centos userland 7 on the raspberrypi with *mythtv

    *Currently, I use an older mythtv version 28.2 in my projects. 
    Usage of older software may NOT make you many friends , if you tell anyone close to upstream. 
    
    Note: This is not the kernel/OS we are talking about here, just the mythtv application.
    I'll update it when i can,  I  personally have a lot of projects I have to  bring into sync when I do.
    Feel free to rebuild your own in the meanwhile. 
    Pretty sure I and others give enough information for one to do that.

2 images Built and available now on SF. Version r01 is xfce4 based and r02 is lxqt based.

https://sourceforge.net/projects/c7rpimyth/


The upstream official "c7 userland" armhfp on the rpi came from the community and people at centos, I took a few sources and 
with livemedia-creator I reworked it a bit and respun it with mythtv and openmax support.


This project will take over where I left off with the raspbian mythtv projects and now those projects will be converted over to  centos 7 "userland(*1) "armhfp based.  Now that I have seen and worked with the stable centos 7 armhfp build system thats now available, its the best for me.
Is it fast as raspbian, no, it takes overclocking it to compare in my brief review, but I still like it since my background has been more rpm based than deb based. I like to build rpms, I dont enjoy building debs.

*LMC sure makes building images easier than the old manual methods either will installroot or half-done methods with livecd-creator. To be fair it's my opinion that LC was never created for the image work LMC evidently was and is extended to do.


c7rpimyth since I respun from their repos with my addons is technically not centos 7 either , but "userland centos linux(*1)" as defined upstream due to changes they made to make it work with rpi.


1.) https://wiki.centos.org/SpecialInterestGroup/AltArch/armhfp




Disclaimer:
Dont be confused I have nothing to do with Centos or Redhat or IBM in any offical capacity. I'm just a nerd with a great hobby and some toys. No one and I mean no one endorsed this project personally or in any way from such said above. What information they did not have publicly made available such as build scripts beyond a leftover kickstart, I deduced on my own and may not be a method they employ at all upstream for image creation. Furthermore, the official project is not responsible for maintaining anything to do with this sub-project spun off of theirs. Ask me for help if you want it or help your self , please. PLEASE, Don't mention sub project spins of hobbyists in upstream project forums as its likely inappropiate. Also, its worth noting if they stop building userland linux base, I may stop building this spin or spins as well. 
Keep in mind just because I made it available for you to respin easily, doesnt mean they UPSTREAM wanted to support that,ever. Last Warning, If you completely disrepect the system, I might not help you make respins so easily in the future as In NO MORE OPEN BUILD SCRIPT INFO or tips.
