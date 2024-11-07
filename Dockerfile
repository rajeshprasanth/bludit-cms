# Start with Alpine Linux base image
FROM alpine:latest

# Install required dependencies: Nginx, PHP, and other utilities
RUN apk update && apk add --no-cache \
    nginx \
    php \
    php-fpm \
    php-opcache \
    php-mysqli \
    php-pdo \
    php-pdo_sqlite \
    php-json \
    php-zlib \
    php-xml \
    php-mbstring \
    bash \
    curl \
    unzip \
    openssl \
    libxml2-dev \
    php-dom \
    php-gd \
    php-session \
    git \
    && rm -rf /var/cache/apk/*

# Install Bludit CMS
WORKDIR /var/www

RUN git clone https://github.com/bludit/bludit.git

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf


# Copy start script to handle environment variables and start services
COPY start.sh /start.sh


RUN chmod +x /start.sh

RUN chown -R nginx:nginx /var/www/bludit


# Expose ports for HTTP (80) and HTTPS (443)
EXPOSE 80 443

# Set the entrypoint to the start script
CMD ["/start.sh"]
