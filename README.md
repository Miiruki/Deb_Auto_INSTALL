---
tags: DPL
title : AGUILAR_Flavien_DPL
author : [AGUILAR Flavien]
titlepage: true
toc-own-page: true
date : "11/02/2021"
---

<div style="text-align:center">

## Préparer l'image de travail :
    
</div>

<div style="text-aling:justify">

</br>

La machine sur laquelle nous allons préparer notre image ISO, est une machine virtuelle debian 10.

Une fois la machien installée, nous allons récupérer l'image iso netinstall situé sur notre machine hôte (Linux Manjarro) : 
    
```
[miiruki@detp:~/Téléchargements $] scp ./debian-10.6.0-amd64-netinst.iso test@10.203.0.101:/home/test
test@10.203.0.101's password: 
debian-10.6.0-amd64-netinst.iso   100%  349MB 114.0MB/s   00:03 
```

Miantenant que l'image est sur la machine virtuelle, nous allons la monter afin de pouvoir la modifier : 

```
test@debian:/test$ sudo mount -o loop debian-10.6.0-amd64-netinst.iso /mnt/
test@debian:/test$ sudo rsync -a -H /mnt/ /test/
test@debian:~$ ls /test/
autorun.inf  dists     g2ldr        isolinux    README.html          README.txt
boot         doc       g2ldr.mbr    md5sum.txt  README.mirrors.html  setup.exe
css          EFI       install      pics        README.mirrors.txt   tools
debian       firmware  install.amd  pool        README.source        win32-loader.ini

```

Comme nous pouvons voir, nous avons bien les fichier permettant de modifier l'image ISO.

Nous allons commencer par télécharger le fichier example-preseed.txt qui va nous servir de modèle pour la configuration de l'image.

```
test@debian:/test$ wget https://www.debian.org/releases/buster/example-preseed.txt
```

Nous allons maitnennat le travailler pour obtenir le fichier suivant : 

```
test@debian:/test$ cat preseed.txt 
d-i debian-installer/locale string fr_FR
d-i keyboard-configuration/xkb-keymap select fr(latin9)
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string flavien
d-i netcfg/get_domain string aguilar
d-i netcfg/wireless_wep string
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.fr.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i passwd/root-password password r00tme
d-i passwd/root-password-again password r00tme
d-i passwd/user-fullname string test
d-i passwd/username string test
d-i passwd/user-password password test
d-i passwd/user-password-again password test
d-i passwd/user-default-groups string audio cdrom video plugdev netdev powerdev
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Paris
d-i clock-setup/ntp boolean true
d-i clock-setup/ntp-server string 0.debian.pool.ntp.org
d-i partman-auto/init_automatically_partition select biggest_free
d-i partman-auto/method string regular
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true
d-i apt-setup/services-select multiselect security
d-i apt-setup/security_host string security.debian.org
d-i apt-setup/cdrom/set-first boolean false
d-i apt-setup/cdrom/set-next boolean false 
d-i apt-setup/cdrom/set-failed boolean false
d-i debian-installer/allow_unauthenticated boolean true
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server build-essential vim
popularity-contest popularity-contest/participate boolean false
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string /dev/sda
d-i finish-install/reboot_in_progress note
d-i cdrom-detect/eject boolean true
d-i debian-installer/exit/reboot boolean true
```

Ce fichier preseed.txt va se situer dans /test/
Nous allons maintenant créer un script qui va générer notre image iso : 

```bash
test@debian:/test$ cat /tmp/install.sh 
#!/bin/sh

cd /test/
md5sum `find -follow -type f`>md5sum.txt
cd ..
genisoimage -o buster-auto.iso -r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat /test/
```

Nous le rendons exécutable : 

```
test@debian:/test$ chmod +x /tmp/install.sh
```

Nous pouvons l'exécuter et récupérer l'image iso stockée dans la racine de la machine : 

```
[miiruki@detp:~ $] scp test@10.203.0.101:/buster-auto.iso .
test@10.203.0.101's password: 
buster-auto.iso                   100%  403MB 147.4MB/s   00:02   
```

Nous avons plus qu'a installer la machine virtuelle en la démarrant sur notre image iso personalisée.

Notre VM est maintenant installée, et nous pouvons nous en servir normalement : 

![](https://i.imgur.com/jj4Oo7n.png)

Nous pouvons maintenant rajouter un outil tel que memtest qui va s'installer sur le grub et qui va nous permettre de vérifier l'état de la ram dans la VM. Pour ce faire, nous allons simplement rajouter la ligne suivante dans le fichier preseed.txt : 

```
d-i pkgsel/include string openssh-server build-essential vim memtest86
```
</div>
