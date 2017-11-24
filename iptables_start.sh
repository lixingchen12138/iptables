#!/bin/bash

DB_IP=10.0.3.11
DB_USER=root
DB_PASSWD=root
DB_NAME=ddos_display

select_sql="select cidr from nation where class=0"
dest_list=$(mysql -h${DB_IP}  -u${DB_USER} -p${DB_PASSWD} ${DB_NAME} -e "${select_sql}"|awk 'NR>1')


select_sql="select cidr from nation where class=2"
src_cidr=$(mysql -h${DB_IP}  -u${DB_USER} -p${DB_PASSWD} ${DB_NAME} -e "${select_sql}"|awk 'NR>1')


delete_sql="delete from iptables where src_cidr='$src_cidr'"
mysql -h${DB_IP}  -u${DB_USER} -p${DB_PASSWD} ${DB_NAME} -e "${delete_sql}"


for dest_cidr in ${dest_list}
do
	insert_sql="insert into iptables values('$src_cidr','$dest_cidr',0)"
	mysql -h${DB_IP}  -u${DB_USER} -p${DB_PASSWD} ${DB_NAME} -e "${insert_sql}"
done


for dest_cidr in ${dest_list}
do
	iptables -D FORWARD -s $src_cidr -d $dest_cidr
done

for dest_cidr in ${dest_list}
do
        iptables -A FORWARD -s $src_cidr -d $dest_cidr
done



for dest_cidr in ${dest_list}
do
{
	sh  iptables.sh $src_cidr $dest_cidr 	
}&
done

