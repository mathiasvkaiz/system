#! /bin/bash
source ../.docker.env
source ../nginx-proxy/.docker.env
source ../gitlab/.docker.env

mkdir -p $NGINX_TEMPLATE_DIR

function generate_conf {
    cat $1 | sed -e "s@\${PROXY_UPSTREAM}@$2@g" \
      -e "s@\${PROXY_IP}@$3@g" \
      -e "s@\${PROXY_PORT}@$4@g" \
      -e "s@\${PROXY_HOSTNAME}@$5@g"
}

function generate_ssl_conf {
    cat $1 | sed -e "s@\${PROXY_UPSTREAM}@$2@g" \
      -e "s@\${PROXY_IP}@$3@g" \
      -e "s@\${PROXY_PORT}@$4@g" \
      -e "s@\${PROXY_HOSTNAME}@$5@g" \
      -e "s@\${PROXY_SSL_CERT_PATH}@$6@g" \
      -e "s@\${PROXY_SSL_CERT_KEY_PATH}@$7@g"
}

function generate_nginx_conf {
  case "$1" in
  0) generate_conf ./.templates/default.conf.template $2 $3 $4 $5 ;;
  1) generate_conf ./.templates/default.wildcard.conf.template $2 $3 $4 $5 ;;
  2) generate_ssl_conf ./.templates/default.ssl.conf.template $2 $3 $4 $5 $6 $7 ;;
  3) generate_ssl_conf ./.templates/default.wildcard.ssl.conf.template $2 $3 $4 $5 $6 $7 ;;
  esac
}

generate_nginx_conf $PROD_DOMAIN_MODE \
  $PROD_UPSTREAM \
  $PROD_PROXY \
  $PROD_PORT \
  $PROD_HOST \
  $PROD_SSL \
  $PROD_SSL_KEY \
  > $NGINX_TEMPLATE_DIR/default.conf.template

generate_nginx_conf $BETA_DOMAIN_MODE \
  $BETA_UPSTREAM \
  $BETA_PROXY \
  $BETA_PORT \
  $BETA_HOST \
  $BETA_SSL \
  $BETA_SSL_KEY \
  >> $NGINX_TEMPLATE_DIR/default.conf.template

generate_nginx_conf $GITLAB_DOMAIN_MODE \
  $GITLAB_UPSTREAM \
  $GITLAB_IP \
  $GITLAB_PORT \
  $GITLAB_HOST \
  $GITLAB_SSL \
  $GITLAB_SSL_KEY >> $NGINX_TEMPLATE_DIR/default.conf.template

generate_nginx_conf $GITLAB_REGISTRY_DOMAIN_MODE \
  $GITLAB_REGISTRY_UPSTREAM \
  $GITLAB_IP \
  $GITLAB_REGISTRY_PORT \
  $GITLAB_REGISTRY_HOST \
  $GITLAB_REGISTRY_SSL \
  $GITLAB_REGISTRY_SSL_KEY >> $NGINX_TEMPLATE_DIR/default.conf.template

generate_nginx_conf $REVIEW_DOMAIN_MODE \
  $REVIEW_UPSTREAM \
  $REVIEW_PROXY \
  $REVIEW_PORT \
  $REVIEW_HOST >> $NGINX_TEMPLATE_DIR/default.conf.template

docker-compose up --build --remove-orphans -d
