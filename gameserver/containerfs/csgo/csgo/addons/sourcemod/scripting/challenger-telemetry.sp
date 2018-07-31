#include <sourcemod>
#include <sdktools>

#undef REQUIRE_EXTENSIONS
#include <SteamWorks>
#include <smjansson>
#include <clients>

#include "challenger/jsonhelpers.sp"

new Handle:PostUrl = INVALID_HANDLE;

/**
 * Declare this as a struct in your plugin to expose its information.
 */
public Plugin myinfo =
{
    name = "Challenger Telemetry Plugin",
    author = "Patrick McClory <pmdev@introspectdat.com>",
    description = "Event-based telemetry forwarder for ChallengerVault application",
    version = "0.1.0",
    url = "https://github.com/challengerinteractive/csgo"
};


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
   PostUrl = CreateConVar("challenger_PostUrl", "http://logging_server:5000", "The Url the events will be posted to.");
   AutoExecConfig(true, "challenger");
   HookEvent("player_death", Event_PlayerDeath);
   //HookEvent("other_death", Event_OtherDeath);
}

//https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#player_death
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
   int victim_id = event.GetInt("userid");
   int attacker_id = event.GetInt("attacker");
   int victim_client = GetClientOfUserId(victim_id);
   int attacker_client = GetClientOfUserId(attacker_id);
   int assister_id = event.GetInt("assister");
   char weapon[64];
   event.GetString("weapon", weapon, sizeof(weapon));
   Handle json = json_object();

   json_object_set_new(json, "timestamp", json_integer(GetTime()));
   set_json_string(json, "event_type", "player_death");

   if(assister_id != 0){
     int assister_client = GetClientOfUserId(assister_id);
     char assister_steam_id[32];
     set_json_int(json, "assister_armor", GetClientArmor(assister_client));
     set_json_int(json, "assister_deaths", GetClientDeaths(assister_client));
     set_json_int(json, "assister_health", GetClientHealth(assister_client));

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
   if (!IsFakeClient(attacker_client)){
     set_json_float(json, "attacker_client_time", GetClientTime(attacker_client));
     char attacker_ip[21];
     if(GetClientIP(attacker_client, attacker_ip, sizeof(attacker_ip))) {
       set_json_string(json, "attacker_ip", attacker_ip);
     }
   }
   
   set_json_string(json, "weapon", weapon);
   set_json_bool(json, "headshot", event.GetBool("headshot", false));
   set_json_int(json, "dominated", event.GetInt("dominated", 0));
   set_json_int(json, "revenge", event.GetInt("revenge", 0));
   set_json_int(json, "penetrated", event.GetInt("penetrated", 0));

   char current_map[32];
   GetCurrentMap(current_map, sizeof(current_map));
   set_json_string(json, "map", current_map);

   set_json_int(json, "steam_server_id", GetServerSteamAccountId());
   char buffer[8192];
   json_dump(json, buffer, sizeof(buffer));
   LogActionToFile("player_death", buffer);
}


public void LogActionToFile(char[] name, char[] message) {
  LogToFile("logs/player_activity.log", "%d - %s - %s - %s", GetTime(), name, "v0.1.0", message);
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
