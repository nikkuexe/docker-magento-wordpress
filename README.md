# Docker Image for Magento 1.8 - 1.9 Bundled with Wordpress

[![](https://images.microbadger.com/badges/image/nintenic/magento-wordpress.svg)](https://microbadger.com/images/nintenic/magento-wordpress)

[![Docker build](http://dockeri.co/image/nintenic/magento-wordpress)](https://hub.docker.com/r/nintenic/magento-wordpress/)

This repo creates a Docker image with both [Magento 1.8 - 1.9.x](http://magento.com/) and [Wordpress](http://wordpress.com) installed, that should run "out of the box" when used with Docker Compose.

### Expected Use

> The goal of this repo is to quickly spin up Docker images for development in Magento 1.8.1 - 1.9.x. It's not intended for production deployment. This repo is only for Magento 1.x. If you are looking for Magento 2.x, check out the work of [alexcheng1982/docker-magento2](https://github.com/alexcheng1982/docker-magento2).

#### Credit

> This repo was made using code and inspiration from [alexcheng1982/docker-magento](https://github.com/alexcheng1982/docker-magento)

## Magento Versions

Version | Git branch | Tag name
--------| ---------- |---------
1.9.3.2 | master     | latest
1.9.2.4 | 1.9.2.4    | 1.9.2.4
1.9.1.1 | 1.9.1.0    | 1.9.1.0
1.9.0.1 | 1.9.0.1    | 1.9.0.1
1.8.1.0 | 1.8.1.0    | 1.8.1.0

## How To Use

Magento is installed into `/var/www/htdocs` folder.
Wordpress is installed into `/var/www/htdocs/wp` folder.

### Docker Compose

[Docker Compose](https://docs.docker.com/compose/) is the recommended way to run this image with MySQL database.

A sample `docker-compose.yml` can be found in this repo.

```yaml
version: '2'

services:
  web:
    container_name: magento-web
    build: .
    ports:
      - "80:80"
    links:
      - mysql
    env_file:
      - env
    depends_on:
      - mysql
    volumes:
      - data-htdocs:/var/www/htdocs
  mysql:
    container_name: magento-mysql
    image: mysql:5.6.23
    env_file:
      - env
    volumes:
      - data-sql:/var/lib/mysql
volumes:
  data-sql:
  data-htdocs:
```

Then use `docker-compose up -d` to start MySQL and Magento server.

### Magento Sample Data & Automated Installation

Installation scripts for Magento are also provided.

Use `/usr/local/bin/install-sampledata` to install sample data for Magento, and `/usr/local/bin/install-magento` for the Magento core. It will use the ENV variables during setup.

```bash
docker exec -it magento-web install-sampledata
docker exec -it magento-web install-magento
```

####Note on sample data
Magento 1.9 sample data is compressed version from [Vinai/compressed-magento-sample-data](https://github.com/Vinai/compressed-magento-sample-data). Magento 1.8, *does not* include sample data.


####Default environment variables

Environment Variable      | Description | Default (used by Docker Compose - `env` file)
--------------------      | ----------- | ---------------------------
MYSQL_HOST                | MySQL host  | mysql
MYSQL_DATABASE            | MySQL db name for Magento | magento
MYSQL_USER                | MySQL username | magento
MYSQL_PASSWORD            | MySQL password | magento
MAGENTO_LOCALE            | Magento locale | en_US
MAGENTO_TIMEZONE          | Magento timezone |Asia/Tokyo
MAGENTO_DEFAULT_CURRENCY  | Magento default currency | USD
MAGENTO_URL               | Magento base url | http://local.magento
MAGENTO_ADMIN_FIRSTNAME   | Magento admin firstname | Admin
MAGENTO_ADMIN_LASTNAME    | Magento admin lastname | MyStore
MAGENTO_ADMIN_EMAIL       | Magento admin email | admin@example.com
MAGENTO_ADMIN_USERNAME    | Magento admin username | admin
MAGENTO_ADMIN_PASSWORD    | Magento admin password | admin123

You can just modify `env` file in the same directory of `docker-compose.yml` file to update those environment variables.

###Hostfile

If you installed with the default compose file and environment variables, you will need to [update your host file](http://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/) to map localhost to `local.magento`.

```
127.0.0.1	local.magento
```

**Important**: If you do not use the default `MAGENTO_URL` you must use a hostname that contains a dot within it (e.g `foo.bar`), otherwise the [Magento admin panel login won't work](http://magento.stackexchange.com/a/7773).

##Working With Data with Kitematic

If you want to work with the data in htdocs (Magento & Wordpress) on your host computer, you will need to first copy the existing data then remap the volume.


```
docker cp magento-web:/var/www/htdocs ./
```

Then you can use Kitematic to configure the /var/www/htdocs volume to point to this data that is accessible on the host system. **Important**: When you configure the volume you will erase everything in /var/www/htdocs so make sure you copy the data BEFORE doing this.

##Mysql Database Notes

The default compose file sets up a mysql database that uses a persistant data volume. This means that so long as the image isn't taken down with `docker down mangento-mysql` or removed from Kitematic, it will retain its data. Here is a cheatsheet of some commands you can run to help manage this data. The following examples assumes you've used the default environment variables.

####Backup all your data

```
docker exec magento-mysql /usr/bin/mysqldump -u root --password=myrootpassword --all-databases > magento-mysql-backup.sql
```

####Restore all your data

```
cat magento-mysql-backup.sql | docker exec -i magento-mysql /usr/bin/mysql -u root --password=myrootpassword --all-databases
```

####You use the same database running but reinstall the magento-web image and get an error about a table already existing

1 - Log into magento-mysql and run `mysql -u root -p` and enter the db root password (default = "myrootpassword").
2 - Once logged into the mysql shell, use the command `use magento;` followed with:
```
DROP TABLE IF EXISTS `permission_variable`,`permission_block`,`customer_flowpassword`;
```

