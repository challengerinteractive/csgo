#!/bin/sh
echo "********************************************************************************"
echo "*"
echo "*  Restarting development CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d && timeout 30 docker-compose logs -f" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d && timeout 30 docker-compose logs -f" &
wait

echo "********************************************************************************"
echo "*"
echo "*  Done restarting development CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"
