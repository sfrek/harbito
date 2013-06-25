#!/bin/bash
function backup_conf_service(){
	local SERVICE=${1}
	local FILE=/opt/${SERVICE}.$(date +%s).conf.tar.gz
	tar zcvf ${FILE} /etc/${SERVICE}*
}

function remove_quantal(){
		# Temporal para eliminar quantal
		PACKAGES=''
		for PKG in $(dpkg -l *quantal* | awk '/^ii/ {print $2}')
		do
			PACKAGES="${PACKAGES} ${PKG}"
		done
		apt-get -y install --reinstall linux-image-server
		apt-get -y remove --purge ${PACKAGES}
		apt-get -y autoremove

		mkdir -p /boot/old
		mv /boot/*-3.5.* /boot/old/
		grub-mkconfig > /boot/grub/grub.cfg
}

SERVICES="nova glance cinder keystone quantum mysql rabbit libvirt openstack"

for SERVICE in ${SERVICES}
do
	PACKAGES=''
	for PACKAGE in $(dpkg -l ${SERVICE}* | awk '/^ii/ {print $2}')
	do
		PACKAGES="${PACKAGES} ${PACKAGE}"
	done
	if [ ! -z "${PACKAGES}" ] 
	then
		backup_conf_service ${SERVICE}
		apt-get -y remove --purge ${PACKAGES}
	fi
done

remove_quantal

apt-get -y update
apt-get -y dist-upgrade
exit 0
