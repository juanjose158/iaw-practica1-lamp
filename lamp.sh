#!/bin/bash

set -x

apt update

apt install apache2 -y

apt install mysql-server -y

DB_ROOT_PASSWD=root

HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario

mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
mysql -u root <<< "FLUSH PRIVILEGES;"

apt install php libapache2-mod-php php-mysql -y


mkdir /var/www/html/adminer
cd /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php
mv adminer-4.7.7-mysql.php index.php

apt install unzip -y

cd/home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

unzip phpMyAdmin-5.0.4-all-languages.zip

rm -rf phpMyAdmin-5.0.4-all-languages.zip

mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin

cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IP_MYSQL/" /var/www/html/phpmyadmin/config.inc.php
sed -i "s/localhost/$IP_MYSQL/" /var/www/html/config.php

apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install goaccess -y

mkdir /var/www/html/stats
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -c $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD 

cp /home/ubuntu/000-default.conf /etc/apache2/sites-available/
systemctl restart apache2



cd /var/www/html
rm -rf iaw-practica-LAMP
git clone https://github.com/josejuansanchez/iaw-practica-LAMP
mv /var/www/html/iaw-parctica-lamp/src/* /var/www/html/


mysql -u root -p$DB_ROOT_PASSWD < /var/www/html/iaw-parctica-lamp/bd/database.sql

rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp

chown www-data:www-data * -R
