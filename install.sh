#!/bin/sh

cd /test/
md5sum `find -follow -type f`>md5sum.txt
cd ..
genisoimage -o buster-auto.iso -r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat /test/
