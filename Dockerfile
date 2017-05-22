FROM php:7.0-cli

MAINTAINER Jonas Erlandsson <jonas.erlandsson@sitedirect.se>

# Install required system packages
RUN apt-get update && \
    apt-get -y install \
            git \
            zlib1g-dev \
            libssl-dev \
            php-mysql \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    zip \
    mysqli  \
    pdo  \
    pdo_mysql

# Install pecl extensions
RUN pecl install mongodb xdebug && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable xdebug

# Configure php
RUN echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo"

# Prepare application
WORKDIR /repo

# Install vendor
COPY ./composer.json /repo/composer.json
RUN composer install --prefer-dist --optimize-autoloader

# Add source-code
COPY . /repo

ENV PATH /repo:${PATH}
ENTRYPOINT ["codecept"]

# Prepare host-volume working directory
RUN mkdir /project
WORKDIR /project
