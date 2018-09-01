#!/bin/sh
echo "********************************************************************************"
echo "*"
echo "*  Restarting PRODUCTION CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-18-236-143-95.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-35-165-84-140.us-west-2.compute.amazonaws.com "docker-compose down && docker-compose up -d" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-18-232-142-175.compute-1.amazonaws.com "docker-compose down && docker-compose up -d" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-34-230-60-12.compute-1.amazonaws.com "docker-compose down && docker-compose up -d" &

echo "********************************************************************************"
echo "*"
echo "*  Done restarting PRODUCTION CSGO servers via docker-compose at $(date)"
echo "*"
echo "********************************************************************************"
