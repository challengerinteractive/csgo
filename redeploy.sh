#!/bin/sh
echo "********************************************************************************"
echo "*"
echo "*  Starting redeploy on $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) at $(date)"
echo "*"
echo "********************************************************************************"
echo ""

OLD_IMAGES=$(docker images -aq 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo)

echo ""
echo "********************************************************************************"
echo "*"
echo "*  Found old images: ${OLD_IMAGES}"
echo "*"
echo "********************************************************************************"

$(aws ecr get-login --no-include-email --registry-ids 367860534964 --region us-west-2)
echo ""
echo "********************************************************************************"
echo "*"
echo "*  Logged into ECR - starting image pulls"
echo "*"
echo "********************************************************************************"
echo ""

time docker pull 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo:latest &
time docker pull 367860534964.dkr.ecr.us-west-2.amazonaws.com/challenger/csgo_event_forwarder:latest &
wait
echo ""
echo "********************************************************************************"
echo "*"
echo "*  Done Pulling Images - bringing csgo server down at $(date)"
echo "*"
echo "********************************************************************************"
echo ""

time docker-compose down

echo ""
echo "********************************************************************************"
echo "*"
echo "*  Starting CSGO Server with new images"
echo "*"
echo "********************************************************************************"
echo ""

time docker-compose up -d

echo ""
echo "********************************************************************************"
echo "*"
echo "*  Removing old images: ${OLD_IMAGES}"
echo "*"
echo "********************************************************************************"
echo ""

docker rmi ${OLD_IMAGES}

echo ""
echo "********************************************************************************"
echo "*"
echo "*  Waiting for CSGO server to be available..."
echo "*"
echo "********************************************************************************"
echo ""

while ! nc -z localhost 27015; do
  sleep 0.1 # wait for 1/10 of the second before check again
  printf "."
done

echo "********************************************************************************"
echo "*"
echo "*  Done with redeploy on $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) at $(date)"
echo "*"
echo "********************************************************************************"

timeout 30s docker-compose logs -f
