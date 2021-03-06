#!/bin/sh

########################################################################
# title:          Build Complete Project
# author:         Yaniv Cohen
# url:            https://github.com/yanivomc/seminars/tree/master/docker/playground/labs/spring-music-docker
# description:    Clone and build complete Spring Music Docker project
# usage:           ./build_project.sh
########################################################################

set -ex
# mount a named volume on host to store mongo and elk data
# ** assumes your project folder is 'music' **
docker volume create --name music_data
docker volume create --name music_elk

# create bridge network for project
# ** assumes your project folder is 'music' **
docker network create -d bridge music_net

# build images and orchestrate start-up of containers (in this order)
docker-compose -p music up -d elk && sleep 15 \
  && docker-compose -p music up -d mongodb && sleep 15 \
  && docker-compose -p music up -d app \
  && docker-compose scale app=3 && sleep 15 \
  && docker-compose -p music up -d proxy && sleep 15

# optional: configure local DNS resolution for application URL
#echo "$(docker-machine ip springmusic)   springmusic.com" | sudo tee --append /etc/hosts

# run a simple connectivity test of application
for i in {1..9}; do curl -I $(docker-machine ip springmusic); done
