#! /bin/bash

for i in ../.projects.env; do
    docker-compose -p ${PROJECT_NAME} up --build --remove-orphans -d

    for i in $( seq 1 $GITLAB_RUNNER_DOCKER_SCALE )
    do
        docker run --rm --volumes-from gitlab-runner_docker_$i gitlab/gitlab-runner register \
        --non-interactive \
        --executor "docker" \
        --docker-image alpine:latest \
        --url "$GITLAB_EXTERNAL_URL/" \
        --registration-token "$GITLAB_RUNNER_TOKEN" \
        --description "${PROJECT_NAME}-docker-$i" \
        --tag-list "docker,aws" \
        --run-untagged=true \
        --locked=false \
        --access-level="not_protected" \
        --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
        --docker-privileged=true
    done

done
