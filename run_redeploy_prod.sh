#!/bin/sh
echo "********************************************************************************"
echo "*"
echo "*  Copying PRODUCTION redeploy script to hosts"
echo "*"
echo "********************************************************************************"

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa redeploy.sh ubuntu@ec2-18-236-143-95.us-west-2.compute.amazonaws.com:~/redeploy.sh &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa redeploy.sh ubuntu@ec2-35-165-84-140.us-west-2.compute.amazonaws.com:~/redeploy.sh &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa redeploy.sh ubuntu@ec2-18-232-142-175.compute-1.amazonaws.com:~/redeploy.sh &
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa redeploy.sh ubuntu@ec2-34-230-60-12.compute-1.amazonaws.com:~/redeploy.sh &
wait
echo "********************************************************************************"
echo "*"
echo "*  Modifying w/ +x to remote PRODUCTION redeploy.sh"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-18-236-143-95.us-west-2.compute.amazonaws.com "sudo chmod +x redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-35-165-84-140.us-west-2.compute.amazonaws.com "sudo chmod +x redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-18-232-142-175.compute-1.amazonaws.com "sudo chmod +x redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-34-230-60-12.compute-1.amazonaws.com "sudo chmod +x redeploy.sh" &
wait

echo "********************************************************************************"
echo "*"
echo "*  Running PRODUCTION redeploy.sh"
echo "*"
echo "********************************************************************************"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-18-236-143-95.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-35-165-84-140.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-18-232-142-175.compute-1.amazonaws.com "./redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-34-230-60-12.compute-1.amazonaws.com "./redeploy.sh" &
wait
