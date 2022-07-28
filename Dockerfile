FROM php:5.6-apache-jessie

# Set maintainer
LABEL description='Debian Jessie machine with PHP5.6 (including Firebird and Oracle modules), Apache2, Git and Composer.'

# Arguments defined in docker-compose.yml
ARG user=user1
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y  \
    curl libpng-dev libzip-dev libonig-dev libxml2-dev zip unzip git

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get Composer
COPY --from=composer:1.10.26 /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring sockets soap zip

# Apache configuration
ENV DOCUMENT_ROOT "/var/www/html"
COPY "./apache2/000-default.conf" "/etc/apache2/sites-available/000-default.conf"
RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && a2enmod rewrite expires remoteip headers
