#!/bin/bash

# ------------------------------------------------------------------------------
# Instalación de la pila LAMP
# ------------------------------------------------------------------------------

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x

# Actualizamos la lista de paquetes
apt update

# Instalamos el servidor web Apache
apt install apache2 -y

# Instalamos el sistema gestor de base de datos
apt install mysql-server -y

# Definimos la contraseña de root
DB_ROOT_PASSWD=root

# Definimos la ruta de la contraseña de usuario
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario

# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
mysql -u root <<< "FLUSH PRIVILEGES;"

# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y

# ------------------------------------------------------------------------------
# Inslación de herramientas adicionales
# ------------------------------------------------------------------------------

# Descargamos Adminers
mkdir /var/www/html/adminer
cd /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php
mv adminer-4.7.7-mysql.php index.php

#--------------------------
# Instalacion de PHPMYADMIM
# -------------------------

# Instalamos la utilidad unzip
apt install unzip -y

# Descargamos el codigo fuente de phpMyadmin
cd/home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

# Descomprimimos el archivo
unzip phpMyAdmin-5.0.4-all-languages.zip

# Borramos el .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip

# Movemos el directorio de phpMyadmin
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin

#Configuramos el archivo config.inc.php
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/0.0.0.0/" /var/www/html/phpmyadmin/config.inc.php
sed -i "s/localhost/0.0.0.0/" /var/www/html/config.php

# Instalación GoAccess
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install goaccess -y

# Crear un directorio para consultar estadisticas
mkdir /var/www/html/stats
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -c $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD 

# Copiar el archivo de configuración
cp /home/ubuntu/000-default.conf /etc/apache2/sites-available/
systemctl restart apache2

# ------------------------------------------------------------------------------
# TODO: Instalación de la aplicación web propuesta
# ------------------------------------------------------------------------------

# Instalación
cd /var/www/html
rm -rf iaw-practica-LAMP
git clone https://github.com/josejuansanchez/iaw-practica-LAMP
mv /var/www/html/iaw-parctica-lamp/src/* /var/www/html/


# Importar script de creacion de la base de datos
mysql -u root -p$DB_ROOT_PASSWD < /var/www/html/iaw-parctica-lamp/bd/database.sql

# Eliminamos contenido inutil
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp

# Cambiar permisos
chown www-data:www-data * -R

# Link repositorio
https://github.com/juanjose158/iaw-practica1-lamp
