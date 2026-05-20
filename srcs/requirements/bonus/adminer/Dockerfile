FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create directory for Adminer
WORKDIR /var/www/html/adminer

# Download Adminer
RUN wget "https://www.adminer.org/latest.php" -O index.php

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# Ensure the run directory for PHP-FPM exists
RUN mkdir -p /run/php

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
