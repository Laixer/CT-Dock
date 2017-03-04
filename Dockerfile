FROM ubuntu:latest
MAINTAINER Yorick de Wid <ydw@byqn.io>

ENV TZ=Europe/Amsterdam

# Install apache, PHP, and supplimentary programs.
RUN apt-get -y update && apt-get -y upgrade \
	&& apt-get -y install wget zip unzip git cron supervisor \
	&& apt-get -y install apache2 npm redis-server postgresql \
	&& apt-get -y install php php-mbstring php-dom php-curl php-pgsql php-gd \
	&& apt-get -y install libapache2-mod-php libxrender1

# Wkhtmltox
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -O wkhtmltox.tar \
	&& tar xvf wkhtmltox.tar \
	&& cp wkhtmltox/bin/* /usr/local/bin/ \
	&& rm -rf wkhtmltox/ \
	&& rm -rf wkhtmltox.tar

# Install bower.
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower

# Fetch composer.
RUN wget https://getcomposer.org/composer.phar -O /usr/bin/composer \
	&& chmod +x /usr/bin/composer

# Manually set up the apache environment variables.
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Copy in config files.
ADD apache2.conf /etc/apache2/apache2.conf
ADD app.conf /etc/apache2/sites-enabled/
ADD redis.conf /etc/redis/redis.conf

# Enable apache mods.
RUN a2enmod rewrite
RUN a2dismod status

# Setup cron
ADD crontab /etc/cron.d/app-cron
RUN chmod 644 /etc/cron.d/app-cron

# Copy this repo into place.
ADD calctool-v2 /var/www/ct
ADD .env /var/www/ct/.env

# Add application owner
RUN useradd -ms /bin/sh eve
RUN chown -R eve:eve /var/www/ct
RUN usermod -a -G eve www-data

# Configure postges.
USER postgres
RUN /etc/init.d/postgresql start \
        && psql --command "CREATE USER eve WITH PASSWORD 'eve';" \
        && createdb -O eve eve

USER eve
WORKDIR /var/www/ct
RUN composer update --no-scripts
RUN composer update
RUN bower update
RUN /var/www/ct/artisan key:gen
ENV APP_DEBUG=1
USER postgres
RUN /etc/init.d/postgresql start \
	&& /var/www/ct/artisan migrate --seed \
	&& /var/www/ct/artisan db:seed --class DemoEnvSeeder

# Expose apache.
EXPOSE 80

# Cleanup
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord", "-n", "-c","/etc/supervisord.conf"]
