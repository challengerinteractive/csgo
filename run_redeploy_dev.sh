#!/bin/sh
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-54-200-35-148.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa ubuntu@ec2-52-33-177-125.us-west-2.compute.amazonaws.com "./redeploy.sh" &
wait
