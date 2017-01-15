FROM deeky666/base

MAINTAINER Steve Müller "deeky666@googlemail.com"

ARG PHP_VERSION

ADD build.sh .

RUN ./build.sh

# Expose volumes for custom configuration, data and log files.
VOLUME ["/php/conf.d", "/php/log", "/php/srv"]

# Define PHP CLI binary as entrypoint.
ENTRYPOINT ["/usr/local/bin/php"]

# Display PHP version information by default
CMD ["-v"]

WORKDIR /php/srv
