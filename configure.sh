#!/bin/bash
set -e
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH"

if [ ! -f ".env" ]; then
  echo "Please copy the sample.env to .env then run this command again."
  exit 1
fi
source .env

chmod 0755 bin/start bin/stop bin/phpmyadmin

if [ ! -d "www/admin" ]; then
  # IMPORTANT: Need to pipe into docker-compose run so it doesn't eat the stdin with 
  # the remainder of the bash script
  # See https://www.reddit.com/r/bash/comments/u8o8y9/comment/i5m9q9g/?utm_source=share&utm_medium=web2x&context=3
  echo "" | docker-compose run  webserver composer create-project "$COMPOSER_TEMPLATE_NAME" "admin"
fi
if [ -f "$SCRIPTPATH/www/admin/configure.env" ]; then
    source "$SCRIPTPATH/www/admin/configure.env"
fi

XATAFACE_APP_ROOT=${XATAFACE_APP_ROOT:-"."}
cat << EOF > www/admin/XATAFACE_APP_ROOT/conf.db.ini.php
;<?php exit;
[_database]
    host = "database"
    user = "$MYSQL_USER"
    password = "$MYSQL_PASSWORD"
    name = "$MYSQL_DATABASE"
    driver=mysqli
EOF


mv www/admin/* www/
if [ -f "www/admin/.gitignore" ]; then
  mv www/admin/.gitignore www/
fi
if [ -f "www/admin/.htaccess" ]; then
  mv www/admin/.htaccess www/
fi
if [ -d "www/admin" ]; then
  rm -r www/admin
fi
if [ -f "www/phpinfo.php" ]; then
  rm www/phpinfo.php
fi
if [ -f "www/test_db.php" ]; then
  rm www/test_db.php
fi
if [ -f "www/test_db_pdo.php" ]; then
  rm www/test_db_pdo.php
fi
