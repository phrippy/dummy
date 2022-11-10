#!/bin/bash
sudo su
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
curl -s https://phrippy-task30.s3.eu-central-1.amazonaws.com/1.txt > /var/www/html/index.html
