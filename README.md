# Bludit CMS Docker Image

This repository provides a **Docker image** for **Bludit CMS**, a simple, fast, and flexible content management system (CMS). The image is pre-configured to run **Bludit** with **Nginx**, **PHP-FPM**, and optional **SSL support**. This makes it easy to deploy Bludit CMS in a containerized environment and set it up quickly on your server.

With this Docker image, you can run Bludit CMS with all the essential components, including Nginx for serving the website, PHP for dynamic content processing, and support for SSL certificates (both self-signed and externally signed).

---

## Features

- **Pre-configured Nginx Web Server**: A lightweight, high-performance web server optimized for serving Bludit CMS.
- **PHP-FPM**: FastCGI Process Manager to efficiently handle PHP requests.
- **SSL Support**: Choose between self-signed SSL certificates or externally signed certificates for HTTPS support.
- **Customizable Plugins and Themes**: Easily integrate your custom plugins and themes using mounted volumes.
- **Persistent Storage**: Use Docker volumes to persist your Bludit content, themes, plugins, and certificates across container restarts.
- **Easy Configuration**: Environment variables allow you to control SSL settings, HTTP or HTTPS mode, and more.

---

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Using Docker Compose](#using-docker-compose)
  - [Access Bludit CMS](#access-bludit-cms)
- [Ports](#ports)
- [Volumes](#volumes)
- [Environment Variables](#environment-variables)
- [License](#license)

---

## Installation

To run **Bludit CMS** using this Docker image, you have two main options:

### Option 1: Using Docker Compose (Recommended)

1. **Clone this repository** or create a `docker-compose.yml` file in your own project folder.
2. **Create a `docker-compose.yml` file** as shown below, and adjust the volumes and environment variables based on your needs:

```yaml
version: '3.8'  # Specifies the version of Docker Compose to use

services:
  bludit-cms:
    image: rajeshprasanth/bludit-cms  # Pull the pre-built image from Docker Hub
    container_name: bludit-cms  # Container name for easy reference
    restart: unless-stopped  # Restart the container unless it is manually stopped
    ports:
      - '5000:80'  # Map HTTP port 80 inside the container to port 5000 on the host
      - '5443:443' # Map HTTPS port 443 inside the container to port 5443 on the host
    environment:
      - HTTP_METHOD=https  # Set to 'http' for non-SSL access or 'https' for SSL access
      - INTERNAL_SSL=1  # Enable internal SSL (set to '0' for external SSL certificates)
    volumes:
      - /path/to/bludit-content:/var/www/bludit/bl-content  # Persist Bludit's content
      - /path/to/custom-certs:/var/www/bludit/custom-certs  # SSL certificates
      - /path/to/custom-plugins:/var/www/bludit/custom-plugins  # Custom plugins
      - /path/to/custom-themes:/var/www/bludit/custom-themes  # Custom themes
    networks:
      - bludit-network  # Connect to a custom network

networks:
  bludit-network:
    driver: bridge  # Use the default bridge network driver
```

3. Run Docker Compose to start the container:
```bash
docker-compose up -d
```
This will automatically download the image from Docker Hub (if not already present locally) and start the container.

### Option 2: Using Docker CLI (Without Docker Compose)

1. Pull the image from Docker Hub:
```bash
docker pull rajeshprasanth/bludit-cms
```
2. Run the container with the following command, adjusting the volumes and environment variables as needed:
```bash
docker run -d \
  --name bludit-cms \
  -p 5000:80 \
  -p 5443:443 \
  -e HTTP_METHOD=https \
  -e INTERNAL_SSL=1 \
  -v /path/to/bludit-content:/var/www/bludit/bl-content \
  -v /path/to/custom-certs:/var/www/bludit/custom-certs \
  -v /path/to/custom-plugins:/var/www/bludit/custom-plugins \
  -v /path/to/custom-themes:/var/www/bludit/custom-themes \
  rajeshprasanth/bludit-cms
```
---
## Configuration

This Docker image comes with default Nginx configuration files. You can customize the Nginx configuration and SSL settings through the following files and environment variables:

### Nginx Configuration Files

  - ```nginx.conf.template```: The main Nginx configuration file.
  - ```nginx.ssl.conf.template```: SSL-specific Nginx configuration file.

These files are copied into the container at build time and can be replaced with custom configurations if needed. The image automatically uses these configuration files to set up Nginx to serve Bludit CMS.
### SSL Configuration

You can enable SSL by setting the environment variable INTERNAL_SSL=1 (for self-signed certificates) or INTERNAL_SSL=0 (to use externally signed certificates). The certificates can be placed in /path/to/custom-certs on your host machine.

---
## Usage

### Using Docker Compose

After running ```docker-compose up -d```, Docker Compose will automatically start the container with the configuration specified in the ```docker-compose.yml``` file.

   - **HTTP**: You can access Bludit CMS via ```http://localhost:5000```.
   - **HTTPS**: You can access Bludit CMS via ```https://localhost:5443```.

### Access Bludit CMS

Bludit CMS should now be running on your server, and you can access it through the following URLs:

- **HTTP (non-SSL)**: `http://localhost:5000`
- **HTTPS (SSL)**: `https://localhost:5443`
    
---

## Ports

- **80** (HTTP): This port is mapped to port 5000 on your host machine. It is used for non-SSL (HTTP) connections.
- **443** (HTTPS): This port is mapped to port 5443 on your host machine. It is used for SSL (HTTPS) connections.

---

## Volumes

To persist your Bludit content, plugins, themes, and SSL certificates, you can mount local directories to the corresponding directories inside the container:

- `/path/to/bludit-content:/var/www/bludit/bl-content`: Bludit’s content (posts, media, etc.) will be stored here.
- `/path/to/custom-certs:/var/www/bludit/custom-certs`: SSL certificates (if using external SSL).
- `/path/to/custom-plugins:/var/www/bludit/custom-plugins`: Custom plugins for Bludit CMS.
- `/path/to/custom-themes:/var/www/bludit/custom-themes`: Custom themes for Bludit CMS.

Make sure that these directories on your host machine exist and are accessible by Docker.


---

## Environment Variables

You can configure the behavior of the container using the following environment variables:

- `HTTP_METHOD`: Set this to `http` for HTTP (non-SSL) access or `https` for SSL access (default: `https`).
- `INTERNAL_SSL`: Set to `1` to use a self-signed SSL certificate or `0` to use externally signed SSL certificates (default: `1`).

---

## License

This Docker image is provided under the MIT License. See the LICENSE file for more information.

---
## Contributions

If you would like to contribute to this project, feel free to submit a pull request or open an issue. We welcome bug fixes, feature improvements, and any suggestions to make this Docker image even better!
