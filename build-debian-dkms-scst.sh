#!/bin/bash
# Build and install Debian SCST dkms-enabled packages.
clear
echo ''
echo "==========================================================="
echo "Establish sudo privileges...                               "
echo "==========================================================="
echo ''
sudo date
echo ''
echo "==========================================================="
echo "Install packages required to build SCST dkms packages...   "
echo "==========================================================="
echo ''
sudo apt-get -q -y install quilt dh-make dh-systemd build-essential devscripts lintian perl gawk dkms >/dev/null 2>&1
echo ''
echo "==========================================================="
echo "Install packages for SCST SAN multipath support...         "
echo "==========================================================="
echo ''
sudo apt-get -q -y install multipath-tools open-iscsi >/dev/null 2>&1

# Get SCST release dynamically

function GetScstRelease {
	sudo grep -R 'SCST_VERSION_NAME' ../../scst-latest/scst/include/scst_const.h | grep -v SCST_VERSION_STRING | cut -f2 -d'"' | cut -f1 -d'-'
}
ScstRelease=$(GetScstRelease)
export ScstRelease="$ScstRelease"
function SetInstallBase {
	pwd | sed "s/latest/$ScstRelease/"
}
InstallBase=$(SetInstallBase)
export INSTALL_BASE=$InstallBase
# echo $INSTALL_BASE
# sleep 5
#Set DKMSMODVER dynamically in debian/rules file
# pwd
# ls -l rules
# echo $ScstRelease
# sleep 5
# sudo sed -i "s/ScstRelease/$ScstRelease/" rules
# echo "sudo sed -i s/ScstRelease/$ScstRelease/ rules"
# grep DKMSMODVER rules | head -1
# sleep 5
echo ''
echo "==========================================================="
echo "Move SCST source directory to version-named directory...   "
echo "==========================================================="
echo ''
cd ../..
# pwd
sleep 5
mv scst-latest scst-"$ScstRelease"
echo ''
echo "==========================================================="
echo "Check source subdir moved to version-named subdir...       "
echo "==========================================================="
echo ''
ls -l scst-"$ScstRelease"
echo ''
echo "==========================================================="
echo "Check DKMSMODVER is $ScstRelease in /debian/rules file...  "
echo "==========================================================="
echo ''
grep DKMSMODVER scst-"$ScstRelease"/debian/rules | head -1
echo ''
sudo rm -rf /usr/src/scst-"$ScstRelease"
sudo mkdir -p /usr/src/scst-"$ScstRelease"
sudo cp -p scst-"$ScstRelease"/debian/dkms.conf.in /usr/src/scst-"$ScstRelease"/dkms.conf
sudo apt-get -y purge scst-dkms
sudo apt-get -y purge iscsi-scst
sudo apt-get -y purge scst-dkms
sudo apt-get -y purge iscsi-scst
sudo apt-get -y purge scstadmin
sudo dpkg -l | grep scst
sudo dkms status | grep scst
sleep 5
sudo dkms remove scst/$ScstRelease --all
sudo rm -r /var/lib/dkms/scst >/dev/null 2>&1
echo ''
sudo dkms add -m scst -v "$ScstRelease"
sleep 5
echo ''
sudo mkdir -p /var/lib/dkms/scst/"$ScstRelease"/dsc
echo ''
echo "==========================================================="
echo "Run cmd: dkms mkdsc -m scst -v $ScstRelease --source-only  "
echo "==========================================================="
echo ''
sudo dkms mkdsc -m scst -v "$ScstRelease" --source-only
echo ''
cd scst-"$ScstRelease"
echo "about to do cp -a"
sleep 2
cp -p ./debian/scst-dkms/usr/src/scst-"$ScstRelease"/scst/include/* ./scst/include/.
sudo cp -a . /usr/src/scst-"$ScstRelease"/.
sleep 2
sudo tar -xzf  /var/lib/dkms/scst/"$ScstRelease"/dsc/scst-dkms_"$ScstRelease".tar.gz -C /usr/src/scst-"$ScstRelease"
sudo mv /usr/src/scst-"$ScstRelease"/scst-dkms-"$ScstRelease" /usr/src/scst-"$ScstRelease"/scst-dkms-mkdsc
echo ''
pwd
echo ''
ls -l
echo ''
echo "==========================================================="
echo "Build the SCST dkms-enabled Debian packages...             "
echo "==========================================================="
echo ''
cd /usr/src/scst-$ScstRelease
# Backup any previously created dkms-enabled SCST debian packages before creating new
export datext=`date +"%Y%m%d_%H%M%S"`
sudo mkdir /usr/src/scst-deb-$datext

sudo mv /usr/src/scst-dkms_"$ScstRelease"_amd64.deb 		/usr/src/scst-deb-$datext/.
sudo mv /usr/src/iscsi-scst_"$ScstRelease"_amd64.deb 	        /usr/src/scst-deb-$datext/.
sudo mv /usr/src/scstadmin_"$ScstRelease"_amd64.deb 		/usr/src/scst-deb-$datext/.
sudo mv /usr/src/scst-fileio-tgt_"$ScstRelease"_amd64.deb 	/usr/src/scst-deb-$datext/.

cd /usr/src/scst-$ScstRelease
echo "==========================================================="
echo "Run cmd: sudo fakeroot debian/rules clean                  "
echo "==========================================================="
echo ''
sudo fakeroot debian/rules clean
echo ''
echo "==========================================================="
echo "Run cmd: sudo fakeroot debian/rules binary                 "
echo "==========================================================="
echo ''
sudo fakeroot debian/rules binary
echo ''
echo "==========================================================="
echo "Install the SCST dkms-enabled Debian packages...           "
echo "==========================================================="
echo ''
# Install SCST packages in correct order ( !! order matters !! )
# GLS 20170723 Working on getting this set using dependencies in the packaging itself
# GLS 20170723 Must remove scst from dkms before installing packages
sudo dkms remove scst/$ScstRelease --all
sudo rm -r /var/lib/dkms/scst >/dev/null 2>&1
# Install the new dkms-enabled scst packages
sleep 5
sudo dpkg -D2 -i /usr/src/scst-dkms_"$ScstRelease"_amd64.deb
sleep 5
sudo dpkg -D2 -i /usr/src/iscsi-scst_"$ScstRelease"_amd64.deb
sleep 5
sudo dpkg -D2 -i /usr/src/scstadmin_"$ScstRelease"_amd64.deb
sleep 5
sudo dpkg -D2 -i /usr/src/scst-fileio-tgt_"$ScstRelease"_amd64.deb
sleep 5
echo ''
echo "==========================================================="
echo "SCST dkms-enabled packages installed                       "
echo "==========================================================="
echo ''
sudo modprobe iscsi-scst
sudo modprobe scst_vdisk
sudo modprobe scst_disk
sudo modprobe scst_user
sudo modprobe scst_modisk
sudo modprobe scst_processor
sudo modprobe scst_raid
sudo modprobe scst_tape
sudo modprobe scst_cdrom
sudo modprobe scst_changer
sudo depmod
sudo iscsi-scstd
sudo systemctl enable scst.service
sudo service scst start
sudo scstadmin -write_config /etc/scst.conf

grep iscsi_scst /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'iscsi-scst'									>> /etc/modules"
fi

grep scst_vdisk /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_vdisk'									>> /etc/modules"
fi

grep scst_disk /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_disk'									>> /etc/modules"
fi

grep scst_user /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_user'									>> /etc/modules"
fi

grep scst_moddisk /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_modisk'									>> /etc/modules"
fi

grep scst_processor /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_processor'								>> /etc/modules"
fi

grep scst_raid /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_raid'									>> /etc/modules"
fi

grep scst_tape /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_tape'									>> /etc/modules"
fi

grep scst_cdrom /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_cdrom'									>> /etc/modules"
fi

grep scst_changer /etc/modules
if [ $? -ne 0 ]
then
sudo sh -c "echo 'scst_changer'									>> /etc/modules"
fi

sudo sh -c "echo '[Unit]'									>  /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'Description=SCST SAN Service'							>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'After=scst.service'								>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo ''										>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo '[Service]'									>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'Type=oneshot'									>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'ExecStart=/usr/bin/sudo /usr/sbin/iscsi-scstd'				>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'ExecStart=/usr/bin/sudo /usr/sbin/scstadmin -config /etc/scst.conf'		>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'RemainAfterExit=true'								>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'ExecStop=/usr/bin/sudo /bin/kill -9 /usr/sbin/iscsi-scstd'			>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'StandardOutput=journal'							>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo ''										>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo '[Install]'									>> /etc/systemd/system/scst-san.service"
sudo sh -c "echo 'WantedBy=multi-user.target'							>> /etc/systemd/system/scst-san.service"
sudo chmod 644 /etc/systemd/system/scst-san.service
sudo systemctl enable scst-san.service
# sudo cat /etc/systemd/system/scst-san.service
# sudo systemctl enable scst-san.service
# sudo sh -c "echo '[Unit]'            	         					 	>  /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'Description=scst-mpath Service'  						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'Wants=network-online.target sw2.service sw3.service scst.service'		>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'After=network-online.target sw2.service sw3.service scst.service'		>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo ''                                 						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo '[Service]'                        						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'Type=oneshot'                     						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'User=root'                        						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'RemainAfterExit=yes'              						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/strt_scst.sh'				>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'ExecStop=/etc/network/openvswitch/stop_scst.sh'				>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo ''                                 						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo '[Install]'                        						>> /etc/systemd/system/scst-mpath.service"
# sudo sh -c "echo 'WantedBy=multi-user.target'       						>> /etc/systemd/system/scst-mpath.service"
# sudo chmod 644 /etc/systemd/system/scst-mpath.service
# sudo systemctl enable scst-mpath.service
echo "==========================================================="
echo "Start and test SCST...                                     "
echo "==========================================================="
echo ''
sudo service scst start
echo ''
sleep 5
ps -ef | grep scst
echo ''
lsmod | grep scst
echo ''
sudo scstadmin -list_group
echo ''
echo "==========================================================="
echo "Set DKMSMODVER back to unset in /debian/rules file...      "
echo "==========================================================="
echo ''
cd $INSTALL_BASE
# sudo sed -i "/DKMSMODVER/s/$ScstRelease/ScstRelease/" rules
# echo ''
#Move SCST source directory back to latest directory
cd ../..
sudo mv scst-"$ScstRelease" scst-latest
cd ./scst-latest/debian
echo "==========================================================="
echo "SCST dkms-enabled install and configuration complete on:   "
echo "==========================================================="
echo ''
if [ -r /etc/lsb-release ]
then
cat /etc/lsb-release
fi


