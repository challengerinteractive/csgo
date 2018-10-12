#!/bin/bash

cat > /tmp/env.sh << EOF
export SERVER_HOSTNAME="ChallengerVault CSGO - Play and Win}"
export RCON_PASSWORD=""
export STEAM_ACCOUNT=""
export CSGO_DIR="/csgo"
export STEAMCMD_DIR="/steamcmd"
export IP="0.0.0.0"
export PORT="27015"
export TICKRATE="128"
export GAME_TYPE="0"
export GAME_MODE="1"
export MAP="de_dust2"
export MAPGROUP="mg_active"
export MAXPLAYERS="16"
export FRIENDLY_FIRE="0"
export SERVER_TAGS="ChallengerVault"
export SRCDS_EXTRA_ARGS=""
export CSGO_SERVER_CFG_EXTRA_OPTIONS=""
EOF

service supervisor restart
