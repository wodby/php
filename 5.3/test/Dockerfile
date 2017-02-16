FROM wodby/php:5.3

ENV PHP_XDEBUG 1

COPY run-tests /usr/local/bin/
COPY php_modules /home/www-data/

CMD ["su-exec", "www-data", "run-tests"]