#!/usr/bin/env bash

DEPENDS="tar aws"
ENVIRONMENT="AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY BACKUP_DIR S3_BUCKET"

echo "== Checking for required commands..."
for COMMAND in $DEPENDS; do
    printf "== Checking for $COMMAND... "
    FOUND=`command -v $COMMAND`
    if ! [ $? ]; then
        echo >&2 " NOT FOUND! Aborting..."
        exit 1
    else
        echo "$FOUND"
    fi
done

echo
echo
echo "== Checking for required environment variables..."
for ENV in $ENVIRONMENT; do
    printf "== Checking environment variable $ENV... "
    if [ -z ${!ENV} ]; then
        echo >&2 "NOT SET! Aborting..."
        exit 1
    else
        echo "OK!"
    fi
done

echo
echo

for DIR in `find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d`; do
    BASENAME=`basename $DIR`
    echo "== Backing up $BASENAME"
    DATE=$(date -u +"%FT%H%MZ")
    TARGET=$S3_BUCKET/backup-$DATE/$BASENAME.tar.bz2
    tar -cvjf - $DIR | aws s3 cp - $TARGET
    echo "== Done backing up $BASENAME to $TARGET"
done

echo
echo
echo "====== $0 done!"