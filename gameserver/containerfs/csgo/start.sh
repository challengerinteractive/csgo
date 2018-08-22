#!/bin/bash

export SERVER_HOSTNAME="${SERVER_HOSTNAME:-ChallengerVault CSGO - Play and Win}"
export RCON_PASSWORD="${RCON_PASSWORD:-}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-}"
export CSGO_DIR="${CSGO_DIR:-/csgo}"
export STEAMCMD_DIR="${STEAMCMD_DIR:-/steamcmd}"
export IP="${IP:-0.0.0.0}"
export PORT="${PORT:-27015}"
export TICKRATE="${TICKRATE:-128}"
export GAME_TYPE="${GAME_TYPE:-0}"
export GAME_MODE="${GAME_MODE:-1}"
export MAP="${MAP:-de_dust2}"
export MAPGROUP="${MAPGROUP:-mg_active}"
export MAXPLAYERS="${MAXPLAYERS:-16}"
export FRIENDLY_FIRE="${FRIENDLY_FIRE:-0}"
export SERVER_TAGS="${SERVER_TAGS:-ChallengerVault}"
export SRCDS_EXTRA_ARGS="${SRCDS_EXTRA_ARGS:-}"
export CSGO_SERVER_CFG_EXTRA_OPTIONS="${CSGO_SERVER_CFG_EXTRA_OPTIONS:-}"
export BOT_JOIN_AFTER_PLAYER="${BOT_JOIN_AFTER_PLAYER:-0}"

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

export REGION_NUMBER="${REGION_NUMBER:-1}"


echo ""
echo "********************************************************************************"
echo ""
echo "    Running steamcmd update..."
echo ""
echo "********************************************************************************"
echo ""
cd $STEAMCMD_DIR
./steamcmd.sh +runscript $CSGO_DIR/csgo_ds.txt

echo ""
echo "********************************************************************************"
echo ""
echo "    Starting CSGO Server..."
echo ""
echo "********************************************************************************"
echo ""
cd $CSGO_DIR

### Create dynamic server config
cat << SERVERCFG > $CSGO_DIR/csgo/cfg/server.cfg
hostname "$SERVER_HOSTNAME"
rcon_password "$RCON_PASSWORD"
sv_lan 0
sv_cheats 0
bot_join_after_player "$BOT_JOIN_AFTER_PLAYER"
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
sv_log_onefile “0″ //Log server information to only one file.
sv_logbans “1″ //Log server bans in the server logs.
sv_logecho “1″ //Echo log information to the console.
sv_logfile “1″ //Log server information in the log file.
sv_logflush “0″ //Flush the log file to disk on each write (slow).
mp_friendlyfire “$FRIENDLY_FIRE″ //Enable Friendly Fire 1 =Enable 0 =Disable
sv_region "$REGION_NUMBER"
sv_tags "$SERVER_TAGS"
$CSGO_SERVER_CFG_EXTRA_OPTIONS
SERVERCFG

./srcds_run \
    -autoupdate \
    -steam_dir $STEAMCMD_DIR/steamcmd.sh \
    -steamcmd_script $CSGO_DIR/csgo_ds.txt \
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
