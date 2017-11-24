#!/bin/bash

DB_IP=10.0.3.11
DB_USER=root
DB_PASSWD=root
DB_NAME=ddos_display

src_cidr=$1
dest_cidr=$2
pre=$(iptables -w -nxvL | grep $dest_cidr | awk '{print $2}')
while true
do
	sleep 3
	current=$(iptables -w -nxvL | grep $dest_cidr | awk '{print $2}')
	#echo $[$current-$pre]
	#echo $src_cidr
	result=$(((current-pre)/3))
	update_sql="update iptables set bytes_s=$result where dest_cidr='$dest_cidr' and src_cidr='$src_cidr'"
	mysql -h${DB_IP}  -u${DB_USER} -p${DB_PASSWD} ${DB_NAME} -e "${update_sql}"
	pre=$current
done

