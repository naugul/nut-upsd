#!/bin/sh
set -xe

cat >/var/run/nut/app/webNUT/webnut/config.py <<EOF
server='127.0.0.1'
port = '3493'
username = 'monitor'
password = '$API_PASSWORD'
EOF

cat >/etc/nut/ups.conf <<EOF
[$UPS_NAME]
	desc = "$UPS_DESC"
	driver = $UPS_DRIVER
	port = $UPS_PORT
EOF

cat >/etc/nut/upsd.conf <<EOF
LISTEN 0.0.0.0 3493
EOF

cat >/etc/nut/upsd.users <<EOF
[admin]
	password = $ADMIN_PASSWORD
	actions = set
	actions = fsd
	instcmds = all

[monitor]
	password = $API_PASSWORD
	upsmon master
EOF

cat >/etc/nut/upsmon.conf <<EOF
MONITOR $UPS_NAME@localhost 1 monitor $API_PASSWORD master
SHUTDOWNCMD "${SHUTDOWN_CMD}"
NOTIFYCMD "UPSNAME=${UPS_NAME} UPSDESC="${UPS_DESC}" SENDTO=${NOTIFY_MAIL} MACADDRESS=${MAC_ADDRESS} /etc/nut/notify.sh"
NOTIFYFLAG ONBATT EXEC
NOTIFYFLAG ONLINE EXEC
NOTIFYFLAG LOWBATT EXEC
NOTIFYFLAG COMMOK EXEC
NOTIFYFLAG COMMBAD EXEC
NOTIFYFLAG REPLBATT EXEC
NOTIFYFLAG NOCOMM EXEC
EOF

echo 'Show all configs...'
echo ''
cat /etc/nut/ups.conf
echo ''
cat /etc/nut/upsd.conf
echo ''
cat /etc/nut/upsd.users
echo ''
cat /etc/nut/upsmon.conf
echo ''
cat /var/run/nut/app/webNUT/webnut/config.py

chgrp -R nut /etc/nut $UPS_PORT
chmod -R o-rwx /etc/nut
cd /var/run/nut/app/webNUT && python setup.py install
cd /var/run/nut/app/webNUT/webnut

/usr/sbin/postfix start
/usr/sbin/upsdrvctl start
/usr/sbin/upsd
exec pserve ../production.ini &
exec /usr/sbin/upsmon -D

