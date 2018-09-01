#!/bin/sh
echo "********************************************************************************"
echo "*"
echo "*  Copying development redeploy script to hosts"
echo "*"
echo "********************************************************************************"

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa redeploy.sh ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com:~/redeploy.sh &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa redeploy.sh ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com:~/redeploy.sh  &
wait
echo "********************************************************************************"
echo "*"
echo "*  Modifying w/ +x to remote development redeploy.sh"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com "sudo chmod +x redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com "sudo chmod +x redeploy.sh" &
wait

echo "********************************************************************************"
echo "*"
echo "*  Running development redeploy.sh"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i deploy_rsa ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com "./redeploy.sh" &
wait
