#!/bin/bash

# This script is used for automatic configuration of LAMP stack
# On Debian based distributions
# For deploy of WordPress application

# Check if script was run with sudo privileges
if [[ $(id -u) -ne 0 ]]
then
  echo "Please run with sudo or as a root." >&2
  exit 1
fi

# Fetch the package lists
apt-get -q=2 update

# Install Apache, PHP, and PHP Modules
apt-get -q=2 install -y apache2 php php-mysqlnd

# Remove Apache Debian default page
rm /var/www/html/index.html

# Start and enable the Apache web server
systemctl start apache2
systemctl enable apache2

# Install MariaDB
apt-get -q=2 install -y mariadb-server

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Create a wordpress database
mysqladmin create wordpress

# Create the user for the wordpress database
mysql -e "GRANT ALL on wordpress.* to wordpress@localhost identified by 'wordpress123';"
mysql -e "FLUSH PRIVILEGES;"

# Secure MariaDB
echo -e "\ny\ny\nrootpassword123\nrootpassword123\ny\ny\ny\ny\n" | mysql_secure_installation

# Download and extract WordPress
TMP_DIR=$(mktemp -d)
cd $TMP_DIR
wget -q https://wordpress.org/wordpress-6.7.2.tar.gz
tar zxf wordpress-6.7.2.tar.gz
mv wordpress/* /var/www/html

# Install the wp-cli tool
apt-get -q=2 install -y php-json
wget -q https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
chmod 755 /usr/local/bin/wp

# Clean up
cd /
rm -rf $TMP_DIR

# Configure WordPress
cd /var/www/html
/usr/local/bin/wp core config --allow-root --dbname=wordpress --dbuser=wordpress \
--dbpass=wordpress123

# Install WordPress
/usr/local/bin/wp core install --allow-root --url=http://10.23.45.60 \
--title="Blog" --admin_user="admin" --admin_password="admin" \
--admin_email="vagrant@localhost.localdomain"