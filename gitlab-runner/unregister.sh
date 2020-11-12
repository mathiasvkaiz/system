#! /bin/bash
source ../system/.docker.env
source ../gitlab/.docker.env

export GITLAB_RUNNER_SCALE=$GITLAB_RUNNER_SCALE

for i in $( seq 1 $GITLAB_RUNNER_SCALE )
do
    docker run --rm --volumes-from runner_docker_$i \
        --network=container:runner_docker_$i \
        gitlab/gitlab-runner unregister --name runner-docker-$i \
        --url ${GITLAB_EXTERNAL_URL} --all-runners
done

for i in $(find ../system/.projects.env ../system/projects.env -type f -name "*.env" 2>/dev/null); do
    source $i
    export GITLAB_RUNNER_SCALE=$GITLAB_RUNNER_SCALE

    for i in $( seq 1 $GITLAB_RUNNER_SCALE )
    do
        docker run --rm --volumes-from ${PROJECT_NAME}_runner_docker_$i \
            --network=container:${PROJECT_NAME}_runner_docker_$i \
            gitlab/gitlab-runner unregister --name ${PROJECT_NAME}-runner-docker-$i \
            --url ${GITLAB_EXTERNAL_URL} --all-runners
    done
done

