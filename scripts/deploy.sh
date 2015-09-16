#!/bin/bash
CSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#include generic functions
. "$CSDIR/genericFunctions.sh"

WEBDOMAIN=$(argValue domain)
GITVERSION=$(argValue version)

if [ "${#WEBDOMAIN}" == "0" ]
then
    WEBDOMAIN=CHANGETOYOURDOMAIN
fi

if [ "${#GITVERSION}" == "0" ]
then
    GITVERSION=master
fi

SERVERDIR=/home/user
FWSLASH=/
SERVERUSR=user
PHPBIN=/usr/local/php56/bin/php

echo "Current script dir: $CSDIR"

date_time=$(date +%Y%m%d_%H%M)
echo "Current script date: $date_time"

archive=$WEBDOMAIN$date_time
archive_name=$archive.zip
sym_link_target="$SERVERDIR/$archive/symfony/web"

echo "Run git archive: $archive_name packing version $GITVERSION"
git archive --format zip --output ./$archive_name $GITVERSION
echo "SCP archive $WEBDOMAIN$date_time.zip to server"
scp $archive_name $SERVERUSR@$WEBDOMAIN:$SERVERDIR
echo "Delete $archive_name "
rm $archive_name


echo "Running remote archive extraction "
ssh $SERVERUSR@$WEBDOMAIN "unzip \"$SERVERDIR$FWSLASH$archive_name\" -d \"$SERVERDIR$FWSLASH$archive\" > /dev/null;   rm \"$SERVERDIR$FWSLASH$archive_name\";"

echo "Set cache and log folders"
ssh $SERVERUSR@$WEBDOMAIN " cd \"$SERVERDIR$FWSLASH$archive\"; cd symfony; rm app/logs; mkdir app/logs; rm app/cache; mkdir app/cache; chmod -R 777 app/logs; chmod -R 777 app/cache"

echo "Run Composer install"
ssh $SERVERUSR@$WEBDOMAIN " cd \"$SERVERDIR$FWSLASH$archive\"; cd symfony; $PHPBIN ~/composer.phar install"

echo "Running cache clearing and assets dumping"
ssh $SERVERUSR@$WEBDOMAIN " cd \"$SERVERDIR$FWSLASH$archive\"; cd symfony; php app/console cache:clear --env prod; php app/console assetic:dump --env prod;"

echo "Deploying app by switching symlink"
ssh $SERVERUSR@$WEBDOMAIN "rm \"$WEBDOMAIN\"; ln -s  \"$sym_link_target\" \"$WEBDOMAIN\";"





