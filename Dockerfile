FROM deeky666/base

MAINTAINER Steve Müller "deeky666@googlemail.com"

ARG PHP_VERSION

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        autoconf \
        make \
        gcc \
        && \

    cd /tmp && \

        wget -O php.tar.gz http://museum.php.net/php5/php-$PHP_VERSION.tar.gz || wget -O php.tar.gz http://www.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror && \
        tar xf php.tar.gz && \

        cd php-$PHP_VERSION && \

        rm configure && \
        ./buildconf --force && \
        ./configure \
            --with-libdir=lib/x86_64-linux-gnu \
            --with-config-file-path=/php/cli \
            --with-config-file-scan-dir=/php/conf.d \
            --disable-cgi \
            --disable-short-tags \
            --without-pear \
            --enable-pdo=shared \
            --enable-mysqlnd=shared \
            --with-pdo-mysql=shared \
            --with-mysqli=shared \
            --with-pdo-pgsql=shared \
            --with-pdo-sqlite=shared \
            --with-sqlite3=shared \
            && \

        make -j`nproc` && \
        make install && \

        make distclean && \
        rm configure && \
        ./buildconf --force && \
        ./configure \
            --with-libdir=lib/x86_64-linux-gnu \
            --with-config-file-path=/php/cli \
            --with-config-file-scan-dir=/php/conf.d \
            --disable-cgi \
            --disable-short-tags \
            --without-pear \
            --with-pdo-mysql=shared,/usr/bin/mysql_config \
            --with-mysqli=shared,/usr/bin/mysql_config && \

        make -j`nproc` && \

        mkdir -p /php/cli /php/conf.d && \

        cd /usr/local/lib/php/extensions/* && \
        mv pdo_mysql.so pdo_mysql-mysqlnd.so && \
        mv mysqli.so mysqli-mysqlnd.so && \
        mv /tmp/php-$PHP_VERSION/modules/pdo_mysql.so pdo_mysql-libmysql.so && \
        mv /tmp/php-$PHP_VERSION/modules/mysqli.so mysqli-libmysql.so && \

        apt-get purge --auto-remove -y wget autoconf make gcc && \
        apt-get clean -y && \
        apt-get autoclean -y && \
        rm -rf /tmp/php* /usr/local/lib/php/build /usr/local/lib/php/extensions/*/*.a /usr/local/include/php

# Expose volumes for custom configuration, data and log files.
VOLUME ["/php/conf.d", "/php/log", "/php/srv"]

# Define PHP CLI binary as entrypoint.
ENTRYPOINT ["/usr/local/bin/php"]

# Display PHP version information by default
CMD ["-v"]

WORKDIR /php/srv
