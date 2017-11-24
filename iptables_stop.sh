ps -ef|grep iptables.sh|grep -v grep|cut -c 9-15|xargs kill -9
