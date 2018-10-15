#!/bin/bash

cat > /etc/challenger_env.sh << EOF
export SERVER_HOSTNAME="ChallengerVault DEV - TEST SERVER"
export RCON_PASSWORD="1H9bMh90XP72"
export STEAM_ACCOUNT="F4AB01263D4479D32CAEB2E294FC9EA0"
export AWS_REGION="us-west-2"
export KINESIS_STREAM_NAME="challenger-staging"
export CSGO_DIR="/csgo"
export STEAMCMD_DIR="/steamcmd"
export IP="0.0.0.0"
export PORT="27015"
export TICKRATE="128"
export GAME_TYPE="1"
export GAME_MODE="2"
export MAP="de_dust2"
export MAPGROUP="mg_active"
export MAXPLAYERS="16"
export FRIENDLY_FIRE="0"
export SERVER_TAGS="ChallengerVault"
export SRCDS_EXTRA_ARGS=""
export CSGO_SERVER_CFG_EXTRA_OPTIONS=""
EOF

service supervisor restart
