#!/bin/bash
#
# Configure git to allow the Bludit repository directory as a safe directory
git config --global --add safe.directory /var/www/bludit

# Print the Bludit version using Git to describe the latest tag
echo "====================================================================="
echo "Bludit V$(git -C /var/www/bludit describe --tags)"
echo "====================================================================="

# Check which HTTP method (protocol) to use: HTTP or HTTPS
method=${HTTP_METHOD}

# If the method is HTTP, run without TLS/SSL
if [ $method == "http" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> Running Without TLS/SSL support"
    # Copy the non-SSL Nginx config template
    cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf
    
# If the method is HTTPS, configure SSL
elif [ $method == "https" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> Running With TLS/SSL support"
    # Copy the SSL-enabled Nginx config template
    cp /etc/nginx/nginx.ssl.conf.template /etc/nginx/nginx.conf
    
    # Check if SSL should be self-signed (INTERNAL_SSL set to 1)
    if [ $INTERNAL_SSL -eq 1 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') >> Generating Self-Signed SSL Certificate."
        # Generate a self-signed SSL certificate using OpenSSL
        openssl req -new -x509 -nodes -out /etc/ssl/certs/fullchain.crt \
        -keyout /etc/ssl/private/privkey.key \
        -days 365 \
        -subj "/CN=localhost"  > /dev/null 2>&1
    
    # Check if an external SSL certificate should be used (INTERNAL_SSL set to 0)
    elif [ $INTERNAL_SSL -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') >> Running with Externally signed SSL Certificate."
        # Copy external SSL certificate and private key to the correct directories
        echo "$(date '+%Y-%m-%d %H:%M:%S') >> Copying Certificate file to /etc/ssl/certs/fullchain.crt"
        cp /var/www/bludit/custom-certs/*crt /etc/ssl/certs/fullchain.crt
        echo "$(date '+%Y-%m-%d %H:%M:%S') >> Copying Private Key file to /etc/ssl/private/privkey.key"
        cp /var/www/bludit/custom-certs/*key /etc/ssl/private/privkey.key
    else
        # If neither option is selected for SSL, show an error message
        echo "Incorrect option. Use 1 to enforce internal or 0 for external ssl certificate"
    fi

# If the protocol is neither "http" nor "https", print an error message
else
    echo "Incorrect protocol in $APP_FULL_BASE_URL"
fi
#

# Check for custom plugins and themes
cnt_plugins=$(ls -1 /var/www/bludit/custom-plugins|wc -l)
cnt_themes=$(ls -1 /var/www/bludit/custom-themes|wc -l)

# If custom plugins are found, copy them into the Bludit plugin directory
if [ $cnt_plugins -gt 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> Custom Plugins found. Copying plugins to /var/www/bludit/bl-plugins/"
    cp -R /var/www/bludit/custom-plugins/* /var/www/bludit/bl-plugins/
else
    # If no custom plugins are found, continue with the built-in plugins
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> No Custom Plugins found. Continuing with built-in plugins"
fi

# If custom themes are found, copy them into the Bludit theme directory
if [ $cnt_themes -gt 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> Custom Themes found. Copying themes to /var/www/bludit/bl-themes/"
    cp -R /var/www/bludit/custom-themes/* /var/www/bludit/bl-themes/
else
    # If no custom themes are found, continue with the built-in themes
    echo "$(date '+%Y-%m-%d %H:%M:%S') >> No Custom Themes found. Continuing with built-in themes"
fi

# Change ownership of the Bludit directory to the 'nginx' user and group for proper file access
chown -R nginx:nginx /var/www/bludit

# Set permissions for the Bludit content directory (allow full access)
chmod -R 777 /var/www/bludit/bl-content

# Set read permissions for the plugins and themes
chmod -R o+r /var/www/bludit/bl-plugins/*
chmod -R o+r /var/www/bludit/bl-themes/*

# Start PHP-FPM to handle PHP requests
/usr/sbin/php-fpm83 &

# Start Nginx web server to serve the site
nginx -g "daemon off;"
