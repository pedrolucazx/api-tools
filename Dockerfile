# Use a imagem base do PHP
FROM php:7.4.33-cli

# Instale as dependências do sistema
RUN apt-get update && apt-get install -y \
  git sqlite3 libsqlite3-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  zip \
  unzip \
  p7zip-full \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd 

# Instale o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Defina a variável de ambiente para permitir a execução do Composer como superusuário
ENV COMPOSER_ALLOW_SUPERUSER 1

# Defina o diretório de trabalho
WORKDIR /var/www/html

# Instale o Laminas API Tools
RUN composer create-project laminas-api-tools/api-tools-skeleton --ignore-platform-reqs --no-interaction .

# Copie o script SQL para criar a tabela
COPY create_table.sql /var/www/html

# Crie a tabela "users" no banco de dados SQLite usando o script
RUN touch database.sqlite && \
  sqlite3 database.sqlite < create_table.sql && \
  rm create_table.sql

# Exponha a porta 8080 do PHP
EXPOSE 8080

# Inicie o Laminas API Tools Skeleton
CMD ["php", "-S", "0.0.0.0:8080", "-t", "public", "public/index.php"]