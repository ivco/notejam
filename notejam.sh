#!/bin/bash
amazon-linux-extras install epel
yum install httpd -y
yum install php -y
yum install php-dom php-mcrypt php-mbstring php-mcrypt php-pdo -y
yum install git -y
systemctl enable httpd
sed -i -e "s/memory_limit = [0-9]*M$/memory_limit = 1024M/" /etc/php.ini

git clone https://github.com/komarserjio/notejam.git /var/www/html

echo 'Alias / /var/www/html/laravel/notejam/public/' >> /etc/httpd/conf/httpd.conf
echo '<Directory "/var/www/html/laravel/notejam/public">' >> /etc/httpd/conf/httpd.conf
echo '       AllowOverride All'  >> /etc/httpd/conf/httpd.conf
echo '       Order allow,deny' >> /etc/httpd/conf/httpd.conf
echo '       allow from all' >> /etc/httpd/conf/httpd.conf
echo '</Directory>' >> /etc/httpd/conf/httpd.conf

systemctl start httpd

cd /var/www/html/laravel/notejam/
curl -sS https://getcomposer.org/installer | sudo php

sudo mv composer.phar /usr/bin/composer
sudo composer install
sudo composer update --prefer-lowest

touch app/database/notejam.db

chown -R apache:apache /var/www/html

sudo php artisan migrate --no-interaction

sed -i '/RewriteEngine On/a RewriteBase /' /var/www/html/laravel/notejam/public/.htaccess
