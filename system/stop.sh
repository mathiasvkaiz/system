#! /bin/bash
if [ -f ../.docker.env ]; then
    source ../.docker.env
else
    source ../.docker.env.example
    export REVIEW_SCALE=0
    export PROD_SCALE=0
    export BETA_SCALE=0
    export SSL_BASEDIR=/etc/letsencrypt
    [ -z $BACKUPDIR ] && export BACKUPDIR=/mnt/backup
    [ ! -z $BACKUPDIR ] && export BACKUPDIR=$BACKUPDIR
fi

docker exec -it system_bootstrapper_1 /system/stop.sh
docker-compose down

docker system prune -f
docker network prune -f
docker volume prune -f
docker image prune -f
