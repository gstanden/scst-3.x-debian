# scst-3.x-debian

Debian dkms-enabled packaging for SCST

### Begin GLS 2017-07-23 Update ###

GLS 2017-07-29 Update

NOTE:  The issues are RESOLVED and this now SHOULD WORK (yay!)

for creating SCST DKMS Packages on Debian-based systemd-enabled Linuxes

such as Ubuntu 15.04+, Linux Mint, etc.

I apologize for the delays getting the issues resolved.

Thanks for your patience.

# SCST

More information on the SCST project here:  http://scst.sourceforge.net/

# Install SCST using this Git

To use this github archive to build and install latest SCST source code as DKMS modules to Ubuntu 17.04:

Go to this link here: 

https://sites.google.com/site/nandydandyoracle/scst/scst-debian-dkms-package-build-from-source-ubuntu-17-04

or if you prefer direct wget:

wget https://sites.google.com/site/nandydandyoracle/scst/scst-debian-dkms-package-build-from-source-ubuntu-17-04/install.sh.v2

and download install.sh.v2 to machine on which want to install SCST DKMS modules.

Read at that same link for instructions (basically just make executable and run from "~/Downloads" dir)

or optionally can edit the "cd ~/Downloads" line and set a different staging area.

# DKMS

DKMS means among other things that you will not have to recompile SCST everytime you upgrade kernel.

DKMS takes care of this for you automatically. 

# References

The following reference was my main relevant reference.

This work could not have been accomplished without the below reference and

the original scst-3.x-debian github by Martijn Grendelman.

More on DKMS here:  https://help.ubuntu.com/community/Kernel/DkmsDriverPackage

Sincere thanks and recognition to the following people who established this github before I forked it.

# Credits

Martijn Grendelman credits Fajar A. Nugraha and Adrian Stachowski for early work on this.
This github was forked from really great github by Martijn Grendelman.
Words are hardly adequate to express my thanks to these pioneering developers.

# Notes

This fork should work with any SCST version although it has only been tested so far with SCST 3.3.0 (latest release)

This fork has been updated for systemd-enabled Debian-based Linuxes (e.g. Ubuntu 17.04 which has been tested).

* tested means scst-dkms modules built/installed successfully

* tested means DKMS rebuilt SCST on kernel upgrades with uninterrupted SCST service across reboots

Releases and Kernels Tested and Known to Work:

* Ubuntu	14.04	Trusty Tahr	3.13.0-125-generic 
* Ubuntu 	15.04	Vivid Vervet	3.19.0-84-generic
* Ubuntu	15.10	Wily Werewolf	4.2.0-42-generic
* Ubuntu 	16.04	Xenial Xerus	4.4.0-84-generic*
* Ubuntu	16.10	Yakkety Yak	4.8.0-59-generic
* Ubuntu	17.04	Zesty Zapus	4.10.0-28-generic

Releases and Kernels Tested that DO NOT WORK:

* Ubuntu 16.04	Xenial Xerus	4.4.0-87-generic
* Ubuntu 16.04	Xenial Xerus	4.4.0-88-generic

(The above tests were done on VirtualBox VM's which had all available updates applied to a vanilla install)

This fork should work on all systemd-enabled Debian-based linuxes (e.g. Linux Mint if using systemd) (not tested yet)

If you test it out, recommend using a dedicated test VM first.

Building SCST with this doesn't require any advanced packaging knowledge, anyone with basic linux skills can use.

# Roadmap

An update to support pre-systemd Debian-based releases (e.g. Ubuntu 14.04) is coming very soon.

If you need to install dkms-enabled SCST on pre-systemd Debian-based release (e.g. Ubuntu 14.04) then:

(1)  Please use the original github this was forked from:  https://github.com/tinuzz/scst-3.x-debian

(2)  Read: https://sites.google.com/site/nandydandyoracle/scst/scst-debian-dkms-package-build-from-source-ubuntu-14-04

# Orabuntu-LXC

SCST is the ISCSI Linux SAN which is bundled with my Orabuntu-LXC:  https://github.com/gstanden/orabuntu-lxc

This work on SCST is driven by that project, but the SCST work is quite general and can be used for any purpose.

# Configure SCST SAN

Included with this github is a tar archive scst-files.tar

Use it optionally to fully-automate SCST file-backed SAN creation and configuration.

The scripts create target, create LUNs, configure multipath, and configure UDEV rules, all fully automated.

Edit create-scst.sh before running and modify parameters on create-scst-oracle.sh to suit your requirements.

To use it untar the scst-files.tar, cd scst-files, and launch ./create-scst.sh and scripts do the rest.

The scripts are easily readable in bash, so you can customize them to meet your needs.

# Uninstall

To uninstall SCST after installing with this fork:

	Run the create-scst-uninstall.sh file in the scst-files.tar archive
	
	A reboot after running create-scst-uninstall.sh is recommended but not mandatory

	If you don't reboot, be sure to kill orphan SCST processes and unload SCST modules

	After reboot check:

	ps -ef | grep scst

	lsmod | grep scst

	Removal should be complete.

	Optionally, you are now ready to reinstall again using this fork following the exact same procedure:

		(just run the build-debian-dkms-scst.sh script as before)

### End GLS 2017-07-23 Update ###

This is an unofficial repository containing Debian packaging for SCST 3.x.
The work was originally done by Fajar A. Nugraha &lt;ubuntu-ppa at fajar dot
net&gt; and I think Adrian Stachowski &lt;ast at marum dot de&gt; before that,
for the packages that can be found in this Launchpad PPA, that serves SCST
packages for Ubuntu Precise, Trusty and Utopic:

https://launchpad.net/~scst/+archive/ubuntu/3.0.x/+packages

Since I haven't been able to find something similar for Debian Jessie or
Wheezy, I adapted Fajar's work for Debian Jessie.

The quick'n'dirty howto for this repo is this:

* check out the source code for SCST from Souceforge (Svn) or Github (Git)
* check out this repository as 'debian' in the source tree
* dpkg-buildpackage / pdebuild / ...

Get the source code here:

* http://sourceforge.net/p/scst/svn/HEAD/tree/branches/3.1.x/
* https://github.com/bvanassche/scst/tree/svn-3.1.x

Use this command to check out a tested revision from Subversion:

  svn checkout svn://svn.code.sf.net/p/scst/svn/branches/3.1.x/@6796 scst-3.1.0

The packaging and the resulting packages HAVE NOT BEEN THOROUGHLY TESTED.
Use them at your own risk. The contents of this repository on every
tagged commit /should/ at least produce a clean build with pbuilder.

If your build fails, you can try this before starting your build tool:

  export CFLAGS="-I`pwd`/scst/include -D_GNU_SOURCE"
