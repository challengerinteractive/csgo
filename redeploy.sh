#!/bin/sh
OLD_IMAGES=$(docker images -aq 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo)
aws ecr get-login --no-include-email --registry-ids 367860534964.dkr.ecr.us-west-2.amazonaws.com --region us-west-2
docker pull 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo:latest
docker-compose down && docker-compose up -d
docker rmi $(OLD_IMAGES)
