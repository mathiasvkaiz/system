#! /bin/bash
shopt -s dotglob

ENV_FILE=../.docker.env
echo > $ENV_FILE
printf "export BOOTSTRAPPER_IP=" > $ENV_FILE
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' system_bootstrapper_1 >> $ENV_FILE

source $ENV_FILE

if [ -f .docker.env ]; then

  source .docker.env

  cd ../gitlab; bash ./start.sh;
  cd ../nginx-proxy; bash ./start.sh;
  cd ../nginx; bash ./start.sh;
  cd ../gitlab-runner; bash ./start.sh;
  cd ../system;

  if [ $SYNC_ENABLE = true ]; then
    cd ../sync; bash ./start.sh; cd ../system;
  fi

  if [ $SYNC_ENABLE = false ]; then
    ./wait-for-it.sh $BOOTSTRAPPER_IP:8071 -t 0
  fi

  echo "stopping environment..."
  bash ./stop.sh

else

  source .seed.env

  cat ../nginx/.templates/default.conf.template | sed -e "s@\${PROXY_UPSTREAM}@sync@g" \
    -e "s@\${PROXY_IP}@$BOOTSTRAPPER_IP@g" \
    -e "s@\${PROXY_PORT}@8071@g" \
    -e "s@\${PROXY_HOSTNAME}@$BOOTSTRAPPER_IP@g" > /synctemplates/default.conf.template

  docker-compose up --build --remove-orphans --force-recreate -d sync

  cd ../sync; bash ./start.sh; cd ../system;

  docker-compose stop sync
fi