#!/bin/bash
sudo su
yum update -y
# yum install -y httpd
# yum install -y httpd php mysql php-mysql
# systemctl start httpd.service
# systemctl enable httpd.service
# echo -n "xxx" > /var/www/html/index.html
mysql --host ${host} \
    --user=${user} \
    --password=${pass} \
    --port=${port} \
    ${name} \
    -e 'status' >/status.txt
# cat <<EOF > /dev/null
yum -y install httpd php mysql php-mysql

case $(ps -p 1 -o comm | tail -1) in
systemd) systemctl enable --now httpd ;;
init)
    chkconfig httpd on
    service httpd start
    ;;
*) echo "Error starting httpd (OS not using init or systemd)." 2>&1 ;;
esac

if [ ! -f /var/www/html/bootcamp-app.tar.gz ]; then
    cd /var/www/html
    wget https://s3.amazonaws.com/immersionday-labs/bootcamp-app.tar
    tar xvf bootcamp-app.tar
    cat <<EOF >/var/www/html/rds.conf.php
<?php \$RDS_URL='${host}'; \$RDS_DB='${name}'; \$RDS_user='${user}'; \$RDS_pwd='${pass}'; ?>
EOF
    chown apache:root /var/www/html/rds.conf.php
    mysql --host ${host} --user ${user} --password ${pass} --port ${port} < /var/www/html/sql/addressbook.sql
fi
# yum -y update
# EOF
