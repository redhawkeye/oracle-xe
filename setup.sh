#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE
export NLS_LANG='$ORACLE_HOME/bin/nls_lang.sh'
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8

apt-get update &&
apt-get install -y libaio1 net-tools bc &&

if [[ ! -f /bin/awk ]]
then
  ln -s /usr/bin/awk /bin/awk
fi

if [[ ! -d /var/lock/subsys ]]
then
  mkdir -p /var/lock/subsys
fi

if [[ ! -f /sbin/chkconfig ]]
then
  cp chkconfig /sbin/chkconfig
  chmod 755 /sbin/chkconfig
fi

cat oracle-xe_11.2.0-1.0_amd64.deba* > oracle-xe_11.2.0-1.0_amd64.deb &&
dpkg -i oracle-xe_11.2.0-1.0_amd64.deb &&
rm oracle-xe_11.2.0-1.0_amd64.deb &&
cp /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora.tmpl &&
cp /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora.tmpl &&
cp init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts &&
cp initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts &&
printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure &&

echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc &&
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc &&
echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc &&
echo "export NLS_LANG='$ORACLE_HOME/bin/nls_lang.sh'" >> /etc/bash.bashrc &&
echo 'export ORACLE_BASE=/u01/app/oracle' >> /etc/bash.bashrc &&
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH' >> /etc/bash.bashrc &&
echo 'export NLS_LANG=AMERICAN_AMERICA.UTF8' >> /etc/bash.bashrc &&

cp startup.sh /usr/sbin/startup.sh &&
chmod +x /usr/sbin/startup.sh &&

echo "ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION NULL;" | sqlplus -s SYSTEM/oracle &&
echo "alter profile DEFAULT limit password_life_time UNLIMITED;" | sqlplus -s SYSTEM/oracle &&
echo "alter user SYSTEM identified by oracle account unlock;" | sqlplus -s SYSTEM/oracle &&
cat apex-default-pwd.sql | sqlplus -s SYSTEM/oracle &&
exit $?
