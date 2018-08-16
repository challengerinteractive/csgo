#!/bin/sh
OLD_IMAGES=$(docker images -aq 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo)
echo "Found old images: ${OLD_IMAGES}"
$(aws ecr get-login --no-include-email --registry-ids 367860534964 --region us-west-2)
docker pull 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo:latest
echo "Restarting csgo server"
docker-compose down && docker-compose up -d
echo "Removing old images"
docker rmi ${OLD_IMAGES}
echo "Done"
