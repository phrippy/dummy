#!/bin/bash
sudo su
yum update -y
# yum install -y httpd
# yum install -y httpd php mysql php-mysql
# systemctl start httpd.service
# systemctl enable httpd.service
# echo -n "xxx" > /var/www/html/index.html
yum -y install httpd php mysql php-mysql
# cat <<EOF > /dev/null

systemctl enable --now httpd

echo until mysql --host ${host} --user ${user} --password ${pass} --port ${port} -e \'SELECT 1;\' >> /log.txt
until mysql --host ${host} --user ${user} --password ${pass} --port ${port} -e \'SELECT 1;\'; do date >> /log.txt; done
echo success >> /log.txt
echo mysql --host ${host} \
    --user=${user} \
    --password=${pass} \
    --port=${port} \
    ${name} \
    -e \'status\' >> /log.txt

mysql --host ${host} \
    --user=${user} \
    --password=${pass} \
    --port=${port} \
    ${name} \
    -e \'status\' > /status.txt

if [ ! -f /var/www/html/bootcamp-app.tar.gz ]; then
    cd /var/www/html
    wget https://s3.amazonaws.com/immersionday-labs/bootcamp-app.tar
    tar xvf bootcamp-app.tar
    cat <<EOF >/var/www/html/rds.conf.php
<?php \$RDS_URL='${host}'; \$RDS_DB='${name}'; \$RDS_user='${user}'; \$RDS_pwd='${pass}'; ?>
EOF
    chown apache:root /var/www/html/rds.conf.php
    mysql --host ${host} --user ${user} --password ${pass} --port ${port} < /var/www/html/sql/addressbook.sql
    echo $? > /result.txt
fi
# yum -y update
# EOF
