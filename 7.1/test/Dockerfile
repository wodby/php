FROM wodby/php:7.1

ENV PHP_XDEBUG 1

COPY run-tests /usr/local/bin/
COPY php_modules /home/www-data/

CMD ["su-exec", "www-data", "run-tests"]