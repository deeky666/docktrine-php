#!/bin/bash

apt-get update -y
apt-get install -y --no-install-recommends \
    wget \
    autoconf \
    make \
    gcc \
    g++

cd /tmp

wget -O php.tar.gz http://museum.php.net/php5/php-$PHP_VERSION.tar.gz || wget -O php.tar.gz http://www.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror
tar xf php.tar.gz

cd php-$PHP_VERSION

CONFIGURE_OPTIONS=""

if [[ $PHP_VERSION == 7* ]]; then
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS --enable-sqlsrv=shared --with-pdo_sqlsrv=shared"

    wget http://pecl.php.net/get/sqlsrv
    tar xf sqlsrv
    rm -f sqlsrv
    mv sqlsrv-* ext/sqlsrv

    wget http://pecl.php.net/get/pdo_sqlsrv
    tar xf pdo_sqlsrv
    rm -f pdo_sqlsrv
    mv pdo_sqlsrv-* ext/pdo_sqlsrv
fi

rm configure
./buildconf --force
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
    --without-sqlite \
    --with-pdo-sqlite=shared,/usr \
    --with-sqlite3=shared \
    $CONFIGURE_OPTIONS \

make -j`nproc`
make install

rm -rf ext/sqlsrv ext/pdo_sqlsrv

make distclean
rm configure
./buildconf --force
./configure \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-config-file-path=/php/cli \
    --with-config-file-scan-dir=/php/conf.d \
    --disable-cgi \
    --disable-short-tags \
    --without-pear \
    --with-pdo-mysql=shared,/usr/bin/mysql_config \
    --with-mysqli=shared,/usr/bin/mysql_config

make -j`nproc`

mkdir -p /php/cli /php/conf.d

cd /usr/local/lib/php/extensions/*
mv pdo_mysql.so pdo_mysql-mysqlnd.so
mv mysqli.so mysqli-mysqlnd.so
mv /tmp/php-$PHP_VERSION/modules/pdo_mysql.so pdo_mysql-libmysql.so
mv /tmp/php-$PHP_VERSION/modules/mysqli.so mysqli-libmysql.so

apt-get purge --auto-remove -y wget autoconf make gcc g++
apt-get clean -y
rm -rf /tmp/php* /usr/local/lib/php/build /usr/local/lib/php/extensions/*/*.a /usr/local/include/php /var/lib/apt/lists/*

useradd -m -s /bin/bash doctrine
