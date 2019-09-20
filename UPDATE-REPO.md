# Update repo for iso

Boot install with curren ISO (vm?) and update/install packages:


cd /root
rpm -qa | sort > pkglist.txt
yum install yum-utils -y
yumdownloader --destdir=packages/ $(cat /root/pkglist.txt | xargs)

After packages have been downloaded:
1. Copy packages from guest to host to packages folder
2. Create iso
