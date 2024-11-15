# Start with Alpine Linux base image to keep the image small and efficient
FROM alpine:latest

# Install required dependencies: Nginx, PHP and additional utilities for Bludit CMS
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
    gawk \
    openssl \
    envsubst \
    unzip \
    && rm -rf /var/cache/apk/*

# Set the working directory for the following commands to /var/www
WORKDIR /var/www

# Clone Bludit CMS from the official GitHub repository
RUN git clone https://github.com/bludit/bludit.git

# Create necessary directories for Bludit CMS customization (certificates, plugins, themes)
RUN mkdir -p /var/www/bludit/custom-certs
RUN mkdir -p /var/www/bludit/custom-plugins
RUN mkdir -p /var/www/bludit/custom-themes

# Copy the Nginx configuration files into the container
# nginx.conf.template is the main Nginx config file
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# nginx.ssl.conf.template for SSL-specific configurations for Nginx
COPY nginx.ssl.conf.template /etc/nginx/nginx.ssl.conf.template

# Copy the start script that will initialize environment variables and start services
COPY start.sh /start.sh

# Make the start script executable
RUN chmod +x /start.sh

# Change ownership of the Bludit directory to nginx user and group (for proper file access)
RUN chown -R nginx:nginx /var/www/bludit

# Expose HTTP (port 80) and HTTPS (port 443) ports for web access
EXPOSE 80 443

# Set the entrypoint to the start script for starting services when the container runs
CMD ["/start.sh"]
