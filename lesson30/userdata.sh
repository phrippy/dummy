#!/bin/bash
sudo su

yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "hello from $(hostname)" > /var/www/html/index.html
