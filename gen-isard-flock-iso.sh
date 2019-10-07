#!/bin/bash
# Build Isard Flock install ISO

VERSION="0.1"
ISO_ORIGINAL="isos/CentOS-7-x86_64-Minimal-1810.iso"
KSFILE="cfg/ks.cfg"
OUTNAME="Isard-Flock_CentOS7_x86_64-v$VERSION.iso"

if [[ ! -f $ISO_ORIGINAL ]]; then
	wget -P isos/ http://ftp.uma.es/mirror/CentOS/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso
fi

WORK=$PWD/WORK
rm -rf $WORK
mkdir $WORK

rm -rf isos/Isard-Flock*

# dir to mount original ISO - SRC
SRC=$WORK/SRC

# dir for customised ISO
DST=$WORK/DST

# Dir for mount EFI image
EFI=$WORK/EFI

# mount ISO to SRC dir
echo "Create $SRC"
mkdir $SRC
echo "Mount original $ISO_ORIGINAL to $SRC"
mount -o loop $ISO_ORIGINAL $SRC

# create dir for  ISO customisation
echo "Create dir $DST for customisation"
mkdir $DST

# copy orginal files to destination dir
# use dot after SRC dir (SRC/.) to help copy hidden files also
cp -v -r $SRC/. $DST/

echo "Umount original ISO $SRC"
umount $SRC

# create dir for EFI image
echo "Create dir for EFIBOOT image - $EFI"
mkdir $EFI

# change rights for rw
echo "Make EFIBOOT RW"
chmod 644 $DST/images/efiboot.img

echo "Mount EFIBOOT image to $EFI"
mount -o loop $DST/images/efiboot.img $EFI/

# add boot menu grab.cfg for UEFI mode
cp -v $(dirname $0)/cfg/efi-boot-grub.cfg $EFI/EFI/BOOT/grub.cfg

# unmount image
echo "Unmount $EFI"
umount $EFI/

# back RO rights
echo "Make EFIBOOT RO"
chmod 444 $DST/images/efiboot.img

# add boot menu grab.cfg for UEFI mode
# It is the second place where boot menu is exists for EFI.
# /images/efiboot.img/{grub.cfg} has the working menu
# /EFI/BOOT/grub.cfg just present (this case has to be discovered)
cp -v $(dirname $0)/cfg/efi-boot-grub.cfg $DST/EFI/BOOT/grub.cfg

# add boot menu with kickstart option to /isolinux (BIOS)
cp -v $(dirname $0)/cfg/isolinux.cfg $DST/isolinux/isolinux.cfg

# put kickstart file custom-ks.cfg to isolinux/ks.cfg
cp -v $KSFILE $DST/isolinux/ks.cfg

# create dir for custom scripts
#~ mkdir -p $DST/extras/ansible/
#~ cp -v -r $(dirname $0)/../ansible/. $DST/extras/ansible/

# copy custom rc.local
#~ cp -v -r $(dirname $0)/cfg/rc.local $DST/extras/

# copy extra RPM to Packages
echo "Copy custom RPM to $DST/Packages"
#~ PACKAGES="$(dirname $0)/packages.txt"
#~ while IFS='' read -r pname || [[ -n "$pname" ]]; do
    #~ cp -v $(dirname $0)/Packages/$pname $DST/Packages/
#~ done < "$PACKAGES"

rm -rf $DST/Packages/*

cp ./packages/* $DST/Packages
cp ./linstor/* $DST/Packages
# Don't need to be copied, will be cloned from isard-flock in ks.cfg
#mkdir $DST/resources
#cp resources/* $DST/resources

#~ cd ./bootisoks/repodata
#~ mv ./*minimal-x86_64-comps.xml comps.xml && {
#~ ls | grep -v comps.xml | xargs rm -rf
#~ }





# update RPM repository index
echo "Update repository index"
(
    cd $DST/;
    chmod u+w repodata/*;
    createrepo -g repodata/*comps.xml . --update;
)

# create output directory
#~ OUTPUT=$WORK/OUTPUT
#~ mkdir $OUTPUT

(
    echo "$PWD - Create custom ISO";
    cd $DST;
    genisoimage \
        -V "CentOS 7 x86_64" \
        -A "CentOS 7 x86_64" \
        -o ../../isos/$OUTNAME \
        -joliet-long \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot -e images/efiboot.img \
        -no-emul-boot \
        -R -J -v -T \
        $DST \
        > ../../isos/out.log 2>&1
)

echo "Isohybrid - make custom iso bootable"
sudo isohybrid --uefi isos/$OUTNAME
echo "You have the image in isos/$OUTNAME"

