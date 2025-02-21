#!/bin/bash

# This script is used for automatic configuration of LAMP stack
# On Red Hat based distributions
# For deploy of WordPress application

# Check if script was run with sudo privileges
if [[ ${UID} -ne 0 ]]
then
  echo "Please run with sudo or as a root." >&2
  exit 1
fi

# Install Apache, PHP, and PHP Modules
dnf -q install -y httpd php php-mysqlnd

# Start and enable the Apache web server
systemctl start httpd
systemctl enable httpd

# Install MariaDB
dnf -q install -y mariadb-server

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Create a wordpress database
mysqladmin create wordpress

# Create the user for the wordpress database
mysql -e "GRANT ALL on wordpress.* to wordpress@localhost identified by 'wordpress123';"
mysql -e "FLUSH PRIVILEGES;"

# Secure MariaDB
echo -e "\n\nrootpassword123\nrootpassword123\n\n\n\n\n" | mysql_secure_installation

# Download and extract WordPress
TMP_DIR=$(mktemp -d)
cd $TMP_DIR
curl -sOL https://wordpress.org/wordpress-5.5.1.tar.gz
tar zxf wordpress-5.5.1.tar.gz
mv wordpress/* /var/www/html

# Install the wp-cli tool
dnf -q install -y php-json
curl -sOL https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
chmod 755 /usr/local/bin/wp

# Clean up
cd /
rm -rf $TMP_DIR

# Configure WordPress
cd /var/www/html
/usr/local/bin/wp core config --dbname=wordpress --dbuser=wordpress \
--dbpass=wordpress123

# Install WordPress
/usr/local/bin/wp core install --url=http://10.23.45.60 \
--title="Blog" --admin_user="admin" --admin_password="admin" \
--admin_email="vagrant@localhost.localdomain"
