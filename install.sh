#!/bin/bash

# This script is used for automatic configuration of LAMP stack
# For deploy of WordPress application written in PHP and MariaDB

# Check if script was run with sudo privileges
if [[ ${UID} -ne 0 ]]
then
  echo "Please run with sudo or as a root." >&2
  exit 1
fi

# Install Apache, PHP, and PHP Modules
echo 'dnf -q install -y httpd php php-mysqlnd'

# Start and enable the web server
echo systemctl start httpd
echo systemctl enable httpd

# Install MariaDB
echo dnf -q install -y mariadb-server

# Start and enable MariaDB
echo systemctl start mariadb
echo systemctl enable mariadb

# Create a wordpress database
echo mysqladmin create wordpress

# Create the user for the wordpress database
echo mysql -e "GRANT ALL on wordpress.* to wordpress@localhost identified by 'wordpress123';"
echo mysql -e "FLUSH PRIVILEGES;"

# Secure MariaDB
echo 'echo -e "\n\nrootpassword123\npassword123\n\n\n\n\n" | mysql secure_installation'

# Remove the test DB privilages
echo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

# Drop the test DB
echo mysqladmin drop -f test

# Remove anonymous DB users
echo msql -e "DELETE FROM mysql.user WHERE User='';"

# Remove remote root DB acount access
echo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

# Set a root DB password
echo mysql -e "UPDATE mysql.user SET Password=PASSWORD('rootpassword123') WHERE User='root';"

# Flush the privileges
echo mysql -e "FLUSH PRIVILEGES;"

# Download and extract WordPress
echo TMP_DIR=$(mktemp -d)
echo cd $TMP_DIR
echo curl -sOL https://wordpress.org/wordpress-5.5.1.tar.gzz
echo tar zxf wordpress-5.5.1.tar.gz
echo mv wordpress/* /var/www/html

# Clean up
echo cd /
echo rm -rf $TMP_DIR

# Install the wp-cli tool
echo dnf -q install -y php-json
echo curl -sOL https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
echo mv wp-cli.phar /usr/local/bin/wp
echo chmod 755 /usr/local/bin/wp

# Configure WordPress
echo cd /var/www/html
echo /usr/local/bin/wp core config --dbname=wordpress -dbuser=wordpress \
--dbpass=wordpress123

# Install WordPress
echo /usr/local/bin/wp core install --url=http://10.23.45.60 \
--title="Blog" --admin_user="admin" --admin_password="admin" \
--admin_email="vagrant@localhost.localdomain"
