FROM php:5.6-apache-jessie

# Set maintainer
LABEL description='Debian Jessie machine with PHP5.6 (including Firebird and Oracle modules), Apache2, Git and Composer.'

# Arguments defined in docker-compose.yml
ARG user=user1
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y  \
    libicu-dev libaio-dev libjpeg-dev libpq-dev libpng-dev libfreetype6-dev  \
    libzip-dev libonig-dev libxml2-dev curl git nano zip unzip firebird-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Defining Aliases
RUN echo 'alias ll="ls -haltr --color"' >> ~/.bashrc

# Get Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Config GitHub on KnownHosts and Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts &&  \
    install -D -v ~/.ssh/known_hosts -t /home/$user/.ssh &&  \
    mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user


# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql sockets soap zip interbase pdo_firebird

# Install Xdebug from source
RUN git clone -b XDEBUG_2_5_5 https://github.com/xdebug/xdebug.git /root/xdebug && cd /root/xdebug && ./rebuild.sh

# Apache configuration
ENV DOCUMENT_ROOT "/var/www/html"
COPY "./apache2/000-default.conf" "/etc/apache2/sites-available/000-default.conf"
RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && a2enmod rewrite expires remoteip headers

# Install the Oracle Instant Client
ADD oracle/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb /tmp
RUN dpkg -i /tmp/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb &&  \
    dpkg -i /tmp/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb &&  \
    dpkg -i /tmp/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb &&  \
    rm -rf /tmp/oracle-instantclient12.1-*.deb

# Set up the Oracle environment variables
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/lib/

# Install the OCI8 PHP extension
RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib' | pecl install -f oci8-2.0.8

# PHP Configurations
COPY "./apache2/php.ini" "$PHP_INI_DIR/php.ini"
