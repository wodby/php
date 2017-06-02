[opcache]
zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20160303/opcache.so
opcache.enable = {{ getenv "PHP_OPCACHE_ENABLE" "1" }}
opcache.validate_timestamps = {{ getenv "PHP_OPCACHE_VALIDATE_TIMESTAMPS" "1" }}
opcache.revalidate_freq = {{ getenv "PHP_OPCACHE_REVALIDATE_FREQ" "2" }}
opcache.max_accelerated_files = {{ getenv "PHP_OPCACHE_MAX_ACCELERATED_FILES" "20000" }}
opcache.memory_consumption = {{ getenv "PHP_OPCACHE_MEMORY_CONSUMPTION" "64" }}
opcache.interned_strings_buffer = {{ getenv "PHP_OPCACHE_INTERNED_STRINGS_BUFFER" "16" }}
opcache.fast_shutdown = {{ getenv "PHP_OPCACHE_FAST_SHUTDOWN" "1" }}

apk add --update         zlib-dev         libpng-dev         libjpeg-turbo-dev         freetype-dev         fontconfig-dev         perl-dev         ghostscript-dev         libwebp-dev         libtool         tiff-dev         lcms2-dev         libxml2-dev &&
    wget -qO- https://github.com/ImageMagick/ImageMagick/archive/7.0.5-9.tar.gz | tar xz -C /tmp/ &&     cd /tmp/ImageMagick-7.0.5-9 &&     ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --infodir=/usr/share/info --without-threads --without-x --with-tiff --with-lcms2 --with-gslib --with-gs-font-dir=/usr/share/fonts/Type1 --with-modules --with-xml &&     mkdir /usr/lib/ImageMagick-7.0.5 &&     make -j1 install &&     find -name '.packlist' -o -name 'perllocal.pod' -o -name '*.bs' -delete &&     install -Dm644 LICENSE /usr/share/licenses/imagemagick/LICENSE &&     mv /usr/lib/libMagick++*.so.* /usr/lib