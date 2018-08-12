#!/bin/bash

export SERVER_HOSTNAME="${SERVER_HOSTNAME:-An Amazing CSGO Server}"
export RCON_PASSWORD="${RCON_PASSWORD:-}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-}"
export CSGO_DIR="${CSGO_DIR:-/csgo}"
export IP="${IP:-0.0.0.0}"
export PORT="${PORT:-27015}"
export TICKRATE="${TICKRATE:-128}"
export GAME_TYPE="${GAME_TYPE:-0}"
export GAME_MODE="${GAME_MODE:-1}"
export MAP="${MAP:-de_dust2}"
export MAPGROUP="${MAPGROUP:-mg_active}"
export MAXPLAYERS="${MAXPLAYERS:-12}"
export FRIENDLY_FIRE="${FRIENDLY_FIRE:1}"
export SERVER_TAGS="ChallengerVault"
export SRCDS_EXTRA_ARGS="${SRCDS_EXTRA_ARGS:-}"
export $CSGO_SERVER_CFG_EXTRA_OPTIONS="${CSGO_SERVER_CFG_EXTRA_OPTIONS:-}"

#Value	Location
#0	US - East
#1	US - West
#2	South America
#3	Europe
#4	Asia
#5	Australia
#6	Middle East
#7	Africa
#255	World (default)

export REGION_NUMBER="${REGION_NUMBER:1}"

export CSGO_DIR="${CSGO_DIR:-/csgo}"

cd $CSGO_DIR

### Create dynamic server config
cat << SERVERCFG > $CSGO_DIR/csgo/cfg/server.cfg
hostname "$SERVER_HOSTNAME"
rcon_password ""
sv_lan 0
sv_cheats 0
writeid
writeip
sv_allow_votes “1″ //Turns server voting on and off.
sv_vote_allow_spectators “0″ //Allow spectators to vote?”
sv_vote_command_delay “2″ //How long after a vote passes until the action happens
sv_vote_creation_time “120″ //How often someone can individually call a vote.
sv_vote_failure_timer “300″ //A vote that fails cannot be re-submitted for this long
sv_vote_quorum_ratio “0″ //The minimum ratio of players needed to vote on an issue to resolve it.
sv_vote_timer_duration “15″ //How long to allow voting on an issue
log on
mp_logfile 1
mp_logdetail 3
mp_logmessages 1
sv_log_onefile “1″ //Log server information to only one file.
sv_logbans “1″ //Log server bans in the server logs.
sv_logecho “1″ //Echo log information to the console.
sv_logfile “1″ //Log server information in the log file.
sv_logflush “0″ //Flush the log file to disk on each write (slow).
mp_friendlyfire “$FRIENDLY_FIRE″ //Enable Friendly Fire 1 =Enable 0 =Disable
sv_tags "$SERVER_TAGS"
$CSGO_SERVER_CFG_EXTRA_OPTIONS
SERVERCFG

./srcds_run \
    -autoupdate \
    -console \
    -usercon \
    -game csgo \
    -tickrate $TICKRATE \
    -port $PORT \
    -maxplayers_override $MAXPLAYERS \
    +game_type $GAME_TYPE \
    +game_mode $GAME_MODE \
    +mapgroup $MAPGROUP \
    +map $MAP \
    +ip $IP \
    +sv_setsteamaccount $STEAM_ACCOUNT \
    +rcon_password $RCON_PASSWORD \
    $SRCDS_EXTRA_ARGS
