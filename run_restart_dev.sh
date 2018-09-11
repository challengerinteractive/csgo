#!/bin/sh

echo "********************************************************************************"
echo "*"
echo "*  Copying development docker-compose.yml to hosts at $(date)"
echo "*"
echo "********************************************************************************"

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa docker-compose.yml ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com:~/docker-compose.yml &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa docker-compose.yml ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com:~/docker-compose.yml  &
wait

echo "********************************************************************************"
echo "*"
echo "*  Copying development docker-compose.env files to hosts at $(date)"
echo "*"
echo "********************************************************************************"

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa _docker-compose.env/dev-deathmatch.env ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com:~/docker-compose.env &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa _docker-compose.env/dev-demolition.env ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com:~/docker-compose.env  &
wait

echo "********************************************************************************"
echo "*"
echo "*  Copying development start.sh files to hosts at $(date)"
echo "*"
echo "********************************************************************************"

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa start_dev.sh ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com:~/start.sh &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa start_dev.sh ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com:~/start.sh  &
wait

echo "********************************************************************************"
echo "*"
echo "*  Restarting development CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d && timeout 45 docker-compose logs -f" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d && timeout 45 docker-compose logs -f" &
wait

echo "********************************************************************************"
echo "*"
echo "*  Done restarting development CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"
