#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod -R 777 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;
sudo echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
# Note that you don't need any prefix to access these variables: for example, you should use 'server_port' and not 'var.server_port'.
sudo echo "<h1>${server_text}</h1>" >> /var/www/html/mysqlinfo.php
sudo echo "<p>User Data Old</p>" >> /var/www/html/mysqlinfo.php
sudo echo "<p>ALB DNS name: ${alb_dns_name}</p>" >> /var/www/html/mysqlinfo.php
sudo echo "<p>ALB listener port: ${alb_listener_port}</p>" >> /var/www/html/mysqlinfo.php
sudo echo "<p>DB address: ${db_address}</p>" >> /var/www/html/mysqlinfo.php
sudo echo "<p>DB port: ${db_port}</p>" >> /var/www/html/mysqlinfo.php
