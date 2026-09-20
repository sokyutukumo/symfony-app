FROM php:8.2-apache

# 1. PostgreSQL 用の PHP 拡張 (pdo_pgsql) および Git / Zip 等をインストール
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libicu-dev \
    libzip-dev \    
    git \
    unzip \
    && docker-php-ext-configure intl \    
    && docker-php-ext-install -j$(nproc) \
        pdo \ 
        pdo_pgsql \
        intl \
        zip \
    && rm -rf /var/lib/apt/lists/*

# 2. Composer のコピー
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Apache のドキュメントルートを public/ に変更 (Symfony標準)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. mod_rewrite 有効化
RUN a2enmod rewrite

WORKDIR /var/www/html/

# 5. 依存パッケージのコピーとインストール
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-req

# 6. アプリ全ファイルのコピー (bin/, src/, migrations/ 等含む)
COPY . /var/www/html/

# 7. オートロード最適化と権限設定
RUN composer dump-autoload --optimize \
    && mkdir -p /var/www/html/var \
    && chown -R www-data:www-data /var/www/html/var

EXPOSE 80
