FROM occitech/magento:php5.5-apache

ENV MAGENTO_VERSION 1.9.2.4
ENV WORDPRESS_VERSION 4.7.3

# Install Sytem Libraries
RUN apt-get update && apt-get install -y mysql-client-5.5 libxml2-dev libcurl3 php5-curl php5-gd php5-mcrypt libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libmcrypt-dev nano
RUN docker-php-ext-install soap
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

# Install Magento
COPY ./files/magento-$MAGENTO_VERSION.tgz /opt/
RUN tar -xzf /opt/magento-$MAGENTO_VERSION.tgz -C /usr/src/
RUN cp -r /usr/src/magento/* /var/www/htdocs \  
  && chown -R www-data:www-data /var/www/htdocs \
  && rm -rf /usr/src/magento

# Install Magento Sample Data
COPY ./files/magento-sample-data-1.9.1.0.tgz /opt/
COPY ./bin/install-magento /usr/local/bin/install-magento
COPY ./bin/install-sampledata-1.9 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-sampledata

# Install Wordpress
COPY ./files/wordpress-$WORDPRESS_VERSION.tar.gz /opt/
RUN tar -xzf /opt/wordpress-$WORDPRESS_VERSION.tar.gz -C /usr/src/
RUN mkdir /var/www/htdocs/wp && cp -r /usr/src/wordpress/* /var/www/htdocs/wp  \
  && rm -rf /usr/src/wordpress

# Setup htdocs Directory
COPY ./files/htaccess.txt /opt/
RUN mv /opt/htaccess.txt /var/www/htdocs/.htaccess
RUN chown -R www-data:www-data /var/www/htdocs
VOLUME /var/www/htdocs

# Setup Apache
COPY ./files/magento.conf /opt/
RUN mv /opt/magento.conf /etc/apache2/sites-available/magento.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/htdocs/' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/htdocs/' /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite magento.conf && a2dissite 000-default.conf
