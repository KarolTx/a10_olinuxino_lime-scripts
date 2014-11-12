#!/bin/sh
### BEGIN INIT INFO
# Provides:          1st-boot
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

LOG_FILE=/root/1st-boot.log
echo 'reconfigure ssh deamons' >> ${LOG_FILE}
dpkg-reconfigure openssh-server >> ${LOG_FILE}
dpkg-reconfigure dropbear >> ${LOG_FILE}

# http://www.cybermilitia.net/2009/02/28/dropbear-on-debian/
echo 'turning off OpenSSH server' >> ${LOG_FILE}
insserv -r ssh >> ${LOG_FILE}
/etc/init.d/ssh stop >> ${LOG_FILE}

echo 'turning on dropbear' >> ${LOG_FILE}
insserv -d dropbear >> ${LOG_FILE}
cat > /etc/dropbear/default <<IEOF
NO_START=0
IEOF
/etc/init.d/dropbear start >> ${LOG_FILE}

echo 'stoping this script' >> ${LOG_FILE}
insserv -r 1st-boot.sh >> ${LOG_FILE}

