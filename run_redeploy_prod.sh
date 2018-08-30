#!/bin/sh
ssh -i ~/.ssh/deploy_rsa ubuntu@ec2-18-236-143-95.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -i ~/.ssh/deploy_rsa ubuntu@ec2-35-165-84-140.us-west-2.compute.amazonaws.com "./redeploy.sh" &
ssh -i ~/.ssh/deploy_rsa ubuntu@ec2-18-232-142-175.compute-1.amazonaws.com "./redeploy.sh" &
ssh -i ~/.ssh/deploy_rsa ubuntu@ec2-34-230-60-12.compute-1.amazonaws.com "./redeploy.sh" &
wait
