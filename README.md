# isard-flock-iso

Minimum packages for isard-flock CentOS custom ISO.
It does require isard-flock submodule, so clone it with either:
- git clone https://github.com/isard-vdi/isard-flock-iso isard-flock
or
- git clone https://github.com/isard-vdi/isard-flock-iso
- git submodule update

## Required packages
```bash
dnf install createrepo syslinux -y
```

## Personalization
1. Edit build.cfg and update mirror URL and/or filename if needed (if it 
fails downloading from the current mirror). Be aware that it will ONLY
work with CentOS 7 x86_64 1810 image.

2. Edit cfg/ks.cfg

	- **language**: lang ca_ES.UTF-8
	- **keyboard**: keyboard es
	- **timezone**: timezone Europe/Madrid
	
	Do not change root password, it is being used in isard-flock install
	script!
