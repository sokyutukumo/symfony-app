FROM php:8.2-apache

# Apache のドキュメントルートを public/ に変更 (Symfony標準)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# mod_rewrite 有効化
RUN a2enmod rewrite

COPY . /var/www/html/
WORKDIR /var/www/html/

EXPOSE 80
