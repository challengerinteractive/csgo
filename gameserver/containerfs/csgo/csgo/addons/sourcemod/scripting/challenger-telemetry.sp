#include <sourcemod>
#include <sdktools>

#undef REQUIRE_EXTENSIONS
#include <SteamWorks>
#include <smjansson>
#include <clients>

#include "challenger/jsonhelpers.sp"

new Handle:PostUrl = INVALID_HANDLE;
new Handle:MatchId = INVALID_HANDLE;
new Handle:RoundId = INVALID_HANDLE;

/**
 * Declare this as a struct in your plugin to expose its information.
 */
public Plugin myinfo =
{
    name = "Challenger Telemetry Plugin",
    author = "Patrick McClory <pmdev@introspectdata.com>",
    description = "Event-based telemetry forwarder for ChallengerVault application",
    version = "v0.1.1",
    url = "https://github.com/challengerinteractive/csgo"
};

public Handle getBaseResponse(const char[] name){
  Handle baseJson = json_object();
  char buffer[48];
  Format(buffer, sizeof(buffer), "server_%s", name);
  set_json_string(baseJson, "event_type", buffer);
  char server_auth_id[64];
  GetServerAuthId(AuthId_SteamID64, server_auth_id, sizeof(server_auth_id));
  set_json_string(baseJson, "server_auth_id", server_auth_id);
  set_json_int(baseJson, "steam_server_id", GetServerSteamAccountId());
  json_object_set_new(baseJson, "timestamp", json_integer(GetTime()));
  char match_id[156];
  GetConVarString(MatchId, match_id, sizeof(match_id));
  set_json_string(baseJson, "match_id", match_id);
  char round_id[156];
  GetConVarString(RoundId, round_id, sizeof(round_id));
  set_json_string(baseJson, "round_id", round_id);
  char current_map[32];
  GetCurrentMap(current_map, sizeof(current_map));
  set_json_string(baseJson, "map", current_map);
  set_json_int(baseJson, "current_client_count", GetClientCount(true));
  return baseJson;
}


/**
 * Called when the plugin is fully initialized and all known external references
 * are resolved. This is only called once in the lifetime of the plugin, and is
 * paired with OnPluginEnd().
 *
 * If any run-time error is thrown during this callback, the plugin will be marked
 * as failed.
 *
 * It is not necessary to close any handles or remove hooks in this function.
 * SourceMod guarantees that plugin shutdown automatically and correctly releases
 * all resources.
 *
 * @noreturn
 */
public void OnPluginStart()
{
   MatchId = CreateConVar("challenger_MatchId", "default_match_id", "The Match ID used for reporting updates to the Challenger Vault system.");
   RoundId = CreateConVar("challenger_RoundId", "default_round_id", "The Round ID used for reporting updates to the Challenger Vault system.");
   PostUrl = CreateConVar("challenger_PostUrl", "http://logging_server:5000", "The Url the events will be posted to.");
   AutoExecConfig(true, "challenger");
   HookEvent("player_death", Event_PlayerDeath);
   HookEvent("player_connect", Event_PlayerConnect);
   HookEvent("player_info", Event_PlayerInfo);
   HookEvent("player_disconnect", Event_PlayerDisconnect);
   HookEvent("player_activate", Event_PlayerActivate);
   HookEvent("player_team", Event_PlayerTeam);
   HookEvent("round_start", Event_RoundStart);
   HookEvent("round_end", Event_RoundEnd);
   HookEvent("game_newmap", Event_NewMap);
   HookEvent("game_start", Event_GameStart);
   HookEvent("game_end", Event_GameEnd);
   HookEvent("begin_new_match", Event_BeginNewMatch, EventHookMode_PostNoCopy);
   HookEvent("cs_intermission", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_poststart", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_officially_ended", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_freeze_end", Event_General, EventHookMode_PostNoCopy);
   HookEvent("cs_game_disconnected", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_announce_match_start", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_announce_last_round_half", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_announce_match_point", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_announce_match_start", Event_General, EventHookMode_PostNoCopy);
   HookEvent("round_time_warning", Event_General, EventHookMode_PostNoCopy);
   HookEvent("cs_match_end_restart", Event_General, EventHookMode_PostNoCopy);
   HookEvent("cs_pre_restart", Event_General, EventHookMode_PostNoCopy);
   HookEvent("client_disconnect", Event_General, EventHookMode_PostNoCopy);

   //HookEvent("other_death", Event_OtherDeath);
}

public void Event_General(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  LogChallengerAction(json)
}

public void Event_BeginNewMatch(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  char server_auth_id[64];
  GetServerAuthId(AuthId_SteamID64, server_auth_id, sizeof(server_auth_id));
  char buffer[162];
  Format(buffer, sizeof(buffer), "match-%s-%d", server_auth_id, GetTime());
  SetConVarString(MatchId, buffer, false, false);
  set_json_string(json, "match_id", buffer);
  LogChallengerAction(json)
}



//https://wiki.alliedmods.net/Generic_Source_Events#round_end
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  int winner_id = event.GetInt("winner");
  char winning_team_name[32];
  GetTeamName(winner_id, winning_team_name, sizeof(winning_team_name));
  set_json_string(json, "winning_team_name", winning_team_name);
  set_json_int(json, "winner_id", winner_id);
  int reason = event.GetInt("reason");
  set_json_int(json, "reason", reason);
  char message[128];
  event.GetString("message", message, sizeof(message));
  set_json_string(json, "message", message);
  LogChallengerAction(json);
}

//https://wiki.alliedmods.net/Generic_Source_Events#game_newmap
public void Event_NewMap(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  char map_name[64];
  event.GetString("mapname", map_name, sizeof(map_name));
  LogChallengerAction(json);
}

//https://wiki.alliedmods.net/Generic_Source_Events#round_start
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  set_json_int(json, "time_limit", event.GetInt("timelimit"));
  set_json_int(json, "frag_limit", event.GetInt("fraglimit"));

  char server_auth_id[64];
  GetServerAuthId(AuthId_SteamID64, server_auth_id, sizeof(server_auth_id));
  char buffer[162];
  Format(buffer, sizeof(buffer), "round-%s-%d", server_auth_id, GetTime());
  SetConVarString(RoundId, buffer, false, false);
  set_json_string(json, "round_id", buffer);

  char objective[128];
  event.GetString("objective", objective, sizeof(objective));
  set_json_string(json, "objective", objective);
  LogChallengerAction(json);
}

//https://wiki.alliedmods.net/Generic_Source_Events#game_start
public void Event_GameStart(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  set_json_int(json, "rounds_limit", event.GetInt("roundslimit"));
  set_json_int(json, "time_limit", event.GetInt("timelimit"));
  set_json_int(json, "frag_limit", event.GetInt("fraglimit"));
  char objective[128];
  event.GetString("objective", objective, sizeof(objective));
  set_json_string(json, "objective", objective);
  LogChallengerAction(json);
}

//https://wiki.alliedmods.net/Generic_Source_Events#player_team
public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  int user_id = event.GetInt("userid");
  int user_client = GetClientOfUserId(user_id);
  if (!IsFakeClient(user_client)){
    //if not a bot, go grab more data...
    char user_steam_id[64]
    if(GetClientAuthId(user_client, AuthId_SteamID64, user_steam_id, sizeof(user_steam_id), false)) {
      set_json_string(json, "user_steam_id", user_steam_id);

      char client_name[128];
      GetClientName(user_client, client_name, sizeof(client_name));
      set_json_string(json, "user_name", client_name);
      int old_team = event.GetInt("oldteam");
      int new_team = event.GetInt("newteam");
      set_json_bool(json, "disconnect", event.GetBool("disconnect"));
      char old_team_name[32];
      GetTeamName(old_team, old_team_name, sizeof(old_team_name));
      set_json_string(json, "old_team_name", old_team_name);
      char new_team_name[32];
      GetTeamName(new_team, new_team_name, sizeof(new_team_name));
      set_json_string(json, "new_team_name", new_team_name);
      LogChallengerAction(json);
    }
  }
}

//https://wiki.alliedmods.net/Generic_Source_Events#game_end
public void Event_GameEnd(Event event, const char[] name, bool dontBroadcast){
  Handle json = getBaseResponse(name);
  int winner_id = event.GetInt("winner");
  char winning_team_name[32];
  GetTeamName(winner_id, winning_team_name, sizeof(winning_team_name));
  set_json_string(json, "winning_team_name", winning_team_name);

  set_json_int(json, "time_limit", event.GetInt("timelimit"));
  set_json_int(json, "frag_limit", event.GetInt("fraglimit"));
  char objective[128];
  event.GetString("objective", objective, sizeof(objective));
  set_json_string(json, "objective", objective);
  LogChallengerAction(json);
}

public void GetClientTeamByUserId(int client_id, char[] team_name, int max_length){
  int client = GetClientOfUserId(client_id);
  int team_id = GetClientTeam(client);
  GetTeamName(team_id, team_name, max_length);
}

public void Event_PlayerActivate(Event event, const char[] name, bool dontBroadcast){
  int user_id = event.GetInt("userid");
  int user_client = GetClientOfUserId(user_id);
  if (!IsFakeClient(user_client)){
    //if not a bot, go grab more data...
    char user_steam_id[64]
    if(GetClientAuthId(user_client, AuthId_SteamID64, user_steam_id, sizeof(user_steam_id), false)) {
      Handle json = getBaseResponse(name);
      set_json_int(json, "user_id", user_id);

      char client_name[128];
      GetClientName(user_client, client_name, sizeof(client_name));
      set_json_string(json, "user_name", client_name);
      char team_name[32];
      GetClientTeamByUserId(user_id, team_name, sizeof(team_name))
      set_json_string(json, "team_name", team_name);
      set_json_string(json, "user_steam_id", user_steam_id);
      LogChallengerAction(json);
    }
  }
}

public void Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
  int user_id = event.GetInt("userid");
  int user_client = GetClientOfUserId(user_id);
  if (user_client != 0 && !IsFakeClient(user_client)){
    Handle json = getBaseResponse(name);

    char client_name[128];
    GetClientName(user_client, client_name, sizeof(client_name));
    set_json_string(json, "user_name", client_name);

    char connect_name[64];
    event.GetString("name", connect_name, sizeof(connect_name));
    set_json_string(json, "name", connect_name);

    set_json_int(json, "user_id", user_id);

    char networkid[64];
    event.GetString("networkid", networkid, sizeof(networkid));
    set_json_string(json, "network_id", networkid);

    char team_name[32];
    GetClientTeamByUserId(user_id, team_name, sizeof(team_name))
    set_json_string(json, "team_name", team_name);

    char steam_id[64];
    GetClientAuthId(user_client, AuthId_SteamID64, steam_id, sizeof(steam_id));
    set_json_string(json, "user_steam_id", steam_id);

    char address[32];
    event.GetString("address", address, sizeof(address));
    set_json_string(json, "address", address);
    set_json_int(json, "bot", event.GetInt("bot"));

    LogChallengerAction(json);
  }
}

public void Event_PlayerInfo(Event event, const char[] name, bool dontBroadcast)
{
  int user_id = event.GetInt("userid");
  int user_client = GetClientOfUserId(user_id);
  if (!IsFakeClient(user_client)){
    Handle json = getBaseResponse(name);

    char disconnect_name[64];
    event.GetString("name", disconnect_name, sizeof(disconnect_name));
    set_json_string(json, "name", disconnect_name);
    set_json_int(json, "user_id", user_id);
    char client_name[128];
    GetClientName(user_client, client_name, sizeof(client_name));
    set_json_string(json, "user_name", client_name);
    char networkid[64];
    event.GetString("networkid", networkid, sizeof(networkid));
    set_json_string(json, "network_id", networkid);

    char team_name[32];
    GetClientTeamByUserId(user_id, team_name, sizeof(team_name))
    set_json_string(json, "team_name", team_name);

    char steam_id[64];
    GetClientAuthId(user_client, AuthId_SteamID64, steam_id, sizeof(steam_id));
    set_json_string(json, "user_steam_id", steam_id);
    set_json_int(json, "bot", event.GetInt("bot"));
    LogChallengerAction(json);
  }
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
  int user_id = event.GetInt("userid");
  int user_client = GetClientOfUserId(user_id);
  if (!IsFakeClient(user_client)){
    Handle json = getBaseResponse(name);
    set_json_int(json, "user_id", user_id);
    char reason[32];
    event.GetString("reason", reason, sizeof(reason));
    set_json_string(json, "reason", reason);
    char networkid[64];
    event.GetString("networkid", networkid, sizeof(networkid));
    set_json_string(json, "network_id", networkid);
    char client_name[128];
    GetClientName(user_client, client_name, sizeof(client_name));
    set_json_string(json, "user_name", client_name);

    char team_name[32];
    GetClientTeamByUserId(user_id, team_name, sizeof(team_name))
    set_json_string(json, "team_name", team_name);

    char steam_id[64];
    GetClientAuthId(user_client, AuthId_SteamID64, steam_id, sizeof(steam_id));
    set_json_string(json, "user_steam_id", steam_id);
    set_json_int(json, "bot", event.GetInt("bot"));
    LogChallengerAction(json);
  }
}

//https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#player_death
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
   int victim_id = event.GetInt("userid");
   int attacker_id = event.GetInt("attacker");
   int victim_client = GetClientOfUserId(victim_id);
   int attacker_client = GetClientOfUserId(attacker_id);
   int assister_id = event.GetInt("assister");
   Handle json = getBaseResponse(name);

   if(assister_id != 0){
     int assister_client = GetClientOfUserId(assister_id);
     char assister_steam_id[32];
     set_json_int(json, "assister_armor", GetClientArmor(assister_client));
     set_json_int(json, "assister_deaths", GetClientDeaths(assister_client));
     set_json_int(json, "assister_health", GetClientHealth(assister_client));

     char assister_team_name[32];
     GetClientTeamByUserId(assister_id, assister_team_name, sizeof(assister_team_name))
     set_json_string(json, "assister_team_name", assister_team_name);

     char assister_weapon[64];
     GetClientWeapon(assister_client, assister_weapon, sizeof(assister_weapon));
     set_json_string(json, "assister_weapon", assister_weapon);
     set_json_int(json, "assister_serial", GetClientSerial(assister_client));

     if (!IsFakeClient(assister_client)){
       //if not a bot, go grab more data...
       set_json_float(json, "assister_client_time", GetClientTime(assister_client));
       if(GetClientAuthId(assister_client, AuthId_SteamID64, assister_steam_id, sizeof(assister_steam_id), false)) {
         set_json_string(json, "assister_steam_id", assister_steam_id);
       }
       char assister_ip[21];
       if(GetClientIP(assister_client, assister_ip, sizeof(assister_ip))) {
         set_json_string(json, "assister_ip", assister_ip);
       }
     }
     char assister_name[128];
     if(GetClientName(assister_client, assister_name, sizeof(assister_name))){
       set_json_string(json, "assiter_name", assister_name);
     }
   }

   char victim_steam_id[32];
   if(GetClientAuthId(victim_client, AuthId_SteamID64, victim_steam_id, sizeof(victim_steam_id), false)) {
     set_json_string(json, "victim_steam_id", victim_steam_id);
   }
   char victim_name[128];
   if(GetClientName(victim_client, victim_name, sizeof(victim_name))){
     set_json_string(json, "victim_name", victim_name);
   }
   set_json_int(json, "victim_serial", GetClientSerial(victim_client));
   set_json_int(json, "victim_armor", GetClientArmor(victim_client));

   char victim_team_name[32];
   GetClientTeamByUserId(victim_id, victim_team_name, sizeof(victim_team_name))
   set_json_string(json, "victim_team_name", victim_team_name);
   set_json_int(json, "victim_deaths", GetClientDeaths(victim_client));
   if (!IsFakeClient(victim_client)){
     set_json_float(json, "victim_client_time", GetClientTime(victim_client));
     char victim_ip[21];
     if(GetClientIP(victim_client, victim_ip, sizeof(victim_ip))){
       set_json_string(json, "victim_ip", victim_ip);
     }
     set_json_float(json, "victim_latency_up", GetClientLatency(victim_client, NetFlow_Incoming));
     set_json_float(json, "victim_latency_down", GetClientLatency(victim_client, NetFlow_Outgoing));
     set_json_float(json, "victim_avg_loss_up", GetClientAvgLoss(victim_client, NetFlow_Incoming));
     set_json_float(json, "victim_avg_loss_down", GetClientAvgLoss(victim_client, NetFlow_Outgoing));
     set_json_float(json, "victim_avg_choke_up", GetClientAvgChoke(victim_client, NetFlow_Incoming));
     set_json_float(json, "victim_avg_choke_down", GetClientAvgChoke(victim_client, NetFlow_Outgoing));
   }
   char victim_weapon[64];
   GetClientWeapon(victim_client, victim_weapon, sizeof(victim_weapon));
   set_json_string(json, "victim_weapon", victim_weapon);

   char attacker_steam_id[32];
   if(GetClientAuthId(attacker_client, AuthId_SteamID64, attacker_steam_id, sizeof(attacker_steam_id), false)) {
     set_json_string(json, "attacker_steam_id", attacker_steam_id);
   }
   char attacker_name[128];
   if(GetClientName(attacker_client, attacker_name, sizeof(attacker_name))){
     set_json_string(json, "attacker_name", attacker_name);
   }
   set_json_int(json, "attacker_serial", GetClientSerial(attacker_client));
   set_json_int(json, "attacker_armor", GetClientArmor(attacker_client));
   set_json_int(json, "attacker_deaths", GetClientDeaths(attacker_client));
   set_json_int(json, "attacker_health", GetClientHealth(attacker_client));

   char attacker_team[32];
   GetClientTeamByUserId(attacker_id, attacker_team, sizeof(attacker_team))
   set_json_string(json, "attacker_team_name", attacker_team);
   if (!IsFakeClient(attacker_client)){
     set_json_float(json, "attacker_client_time", GetClientTime(attacker_client));
     char attacker_ip[21];
     if(GetClientIP(attacker_client, attacker_ip, sizeof(attacker_ip))) {
       set_json_string(json, "attacker_ip", attacker_ip);
     }
   }

   char weapon[64];
   event.GetString("weapon", weapon, sizeof(weapon));
   set_json_string(json, "weapon", weapon);
   set_json_bool(json, "headshot", event.GetBool("headshot", false));
   set_json_int(json, "dominated", event.GetInt("dominated", 0));
   set_json_int(json, "revenge", event.GetInt("revenge", 0));
   set_json_int(json, "penetrated", event.GetInt("penetrated", 0));
   LogChallengerAction(json);
}


public void LogChallengerAction(Handle jsonLog) {
  char event_type[32];
  Handle evt_type = json_object_get(jsonLog, "event_type");
  json_string_value(evt_type, event_type, sizeof(event_type));
  char message[8196];
  json_dump(jsonLog, message, sizeof(message));
  LogToFile("logs/player_activity.log", "%d - %s - %s - %s", GetTime(), event_type, PlInfo_Version, message);
  LogActionToHttp(event_type, message);
}

public void LogActionToHttp(char[] name, char[] message){
  if(PostUrl == INVALID_HANDLE){
    return;
  }
  char sPostUrl[512];
  GetConVarString(PostUrl, sPostUrl, sizeof(sPostUrl));
  Handle request_SendValue = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://logging_server:5000");
  SteamWorks_SetHTTPRequestRawPostBody(request_SendValue, "application/json", message, strlen(message));
  SteamWorks_SetHTTPCallbacks(request_SendValue, OnSteamWorksHTTPComplete);
  SteamWorks_SendHTTPRequest(request_SendValue);
}

public int OnSteamWorksHTTPComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data) {
  if (!bRequestSuccessful && eStatusCode != k_EHTTPStatusCode200OK){
    char sError[256];
    FormatEx(sError, sizeof(sError), "HTTP Logging Error error (status code %i). Request successful: %s", _:eStatusCode, bRequestSuccessful ? "True" : "False");
    LogError(sError);
  }
  delete hRequest;
}
