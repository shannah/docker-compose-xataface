#!/bin/bash
set -e
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH"
if [ ! -f ".env" ]; then
  echo "Please copy the sample.env to .env then run this command again."
  exit 1
fi
source .env

docker-compose up -d
if [ ! -d "www/admin" ]; then
  docker-compose exec webserver composer create-project "$COMPOSER_TEMPLATE_NAME" "admin"
fi
cat << EOF > www/admin/conf.db.ini.php
;<?php exit;
[_database]
    host = "database"
    user = "$MYSQL_USER"
    password = "$MYSQL_PASSWORD"
    name = "$MYSQL_DATABASE"
    driver=mysqli
EOF
mv www/admin/* www/
mv www/admin/.* www/
rm -r www/admin
rm www/phpinfo.php
rm www/test_db.php
rm www/test_db_pdo.php





