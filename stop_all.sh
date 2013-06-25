#!/bin/bash
function stop_service(){
	local SERVICE=${1}
	for INIT in $(ls /etc/init.d/${SERVICE}* 2>&-)
	do
		echo "service ${INIT##*/} stop"
		service ${INIT##*/} stop
	done
}

function del_all_br(){
	if [ -e /var/run/openvswitch/db.sock ]
	then
		for BRIDGE in $(ovs-vsctl list-br)
		do
			ovs-vsctl del-br ${BRIDGE}
		done
	fi
	stop_service openvswitch
}

function undefine_libvirt_network(){
	for NET in $(virsh -q net-list --all | cut -f1 -d' ')
	do
		virsh net-autostart --disable ${NET}
		virsh net-undefine ${NET}
	done
}

SERVICES="nova glance cinder keystone quantum mysql rabbit libvirt"

for SERVICE in ${SERVICES}
do
	case ${SERVICE} in
		quantum)
			stop_service ${SERVICE}
			del_all_br
			;;
		libvirt)
			undefine_libvirt_network
			stop_service ${SERVICE}
			;;
		*)
			stop_service ${SERVICE}
			;;
	esac
done

exit 0
