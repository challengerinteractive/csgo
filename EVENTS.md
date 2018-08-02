# CS:GO server side events

This server plugin for Counterstrike: Global Offensive captures data from the game server and forwards it to an aggregator which then submits data to the Amazon Kinesis stream which the backend Event Processor then consumes.

This build includes a custom plugin compilation process for a SourceMod plugin. The following resource might be helpful if you're trying to follow along:

* [API Reference](https://sm.alliedmods.net/new-api/)
* [General Game Events](https://wiki.alliedmods.net/Generic_Source_Server_Events)
* [Counterstrike:GO Game Events](https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events)

# Kinesis Events

The following are `event_types` for events pushed to AWS Kinesis from the CS:GO server plugin. All server events have a common base structure as follows:

```json
{
	"event_type": "server_player_death",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169320.0697036",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
		"timestamp": 1533169320,
		"steam_server_id": 2409689,
		"map": "de_dust2"
	}
}
```

* event_type - string - indicates type of event (see headings below)
* game - object
    * id - str(int) - ID of the game - 730 is Steam's ID for Counterstrike: GO
    * name - str - shorthand name for the game (in case of ID collision by platform)
    * type - str - type of game
    * platform - str - name of the platform the game is being played on
* server - object - this is data about the server itself at the time logs are forwarded (derived from python, not CSGO)
    * ip - str - public IP address of the server
    * mode - str(int) - server mode (https://pkrhosting.co.uk/knowledgebase/8/How-to-change-the-gamemode-of-the-csgo-server.html)
    * type - str(int) - server type (https://pkrhosting.co.uk/knowledgebase/8/How-to-change-the-gamemode-of-the-csgo-server.html)
    * timestamp - str(float) - precise timestamp log was forwarded (good for understanding latency between game and log receipt)
    * name - str - name of the server itself (as it would show up in the in-game server browser)
* payload - object - this holds all in-game derived values along with the following common values
    * timestamp - str(int) - in-game timestamp for when data grabbed from game - from [GetTime](https://sm.alliedmods.net/new-api/sourcemod/GetTime)
    * steam_server_id - str(int) - Steam ID of the owner of the server (of the server key used to run this instance) from [GetServerSteamAccountId](https://sm.alliedmods.net/new-api/halflife/GetServerSteamAccountId)
    * map - str - map name from [GetCurrentMap](https://sm.alliedmods.net/new-api/halflife/GetCurrentMap)


## `server_player_death`

The `player_death` event fires whenever there's a death in the game, regardless of who or what kind of user it was. This is the most complicated to parse as there are three parts:

* attacker
* victim
* assister

For each of these 'roles' in a player death event, if the user is not a bot user, we append additional information for the user such as their Steam ID, and IP and client time. Additionally, for the victim, if they aren't a bot, we also pull data on their network latency. On top of this, note that sometimes there's an assister, sometimes there's not. The payload fields are pretty much sourced directly from the [event data](https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#player_death) and the following functions:

* Bot detection - [IsFakeClient](https://sm.alliedmods.net/new-api/clients/IsFakeClient)
* `victim_avg_loss_(up|down)` - [GetClientAvgLoss](https://sm.alliedmods.net/new-api/clients/GetClientAvgLoss)
* `victim_latency_(up|down)` - [GetclientLatency](https://sm.alliedmods.net/new-api/clients/GetClientLatency)
* `victim_avg_choke_(up|down)` - [GetClientAvgChoke](https://sm.alliedmods.net/new-api/clients/GetClientAvgChoke)
* `name_serial` - [GetClientSerial](https://sm.alliedmods.net/new-api/clients/GetClientSerial)
* `name_armor` - [GetClientArmor](https://sm.alliedmods.net/new-api/clients/GetClientArmor)
* `name_deaths` - [GetClientDeaths](https://sm.alliedmods.net/new-api/clients/GetClientDeaths)
* `name_time` - 	[GetClientTime](https://sm.alliedmods.net/new-api/clients/GetClientTime)
* `name_ip` - [GetClientIP](https://sm.alliedmods.net/new-api/clients/GetClientIP)
* `name_name` - [GetClientName](https://sm.alliedmods.net/new-api/clients/GetClientName)
* `name_steam_id` - [GetClientAuthId](https://sm.alliedmods.net/new-api/clients/GetClientAuthId)
* `name_weapon` - [GetClientWeapon](https://sm.alliedmods.net/new-api/clients/GetClientWeapon)

Where `name` is one of ['victim', 'attacker', 'assister']

### Example - All Bots

```json
{
	"event_type": "player_death",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169320.0697036",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
    "map": "de_dust2",
    "timestamp": 1533169320,
    "steam_server_id": 2409689,
		"headshot": false,
		"victim_weapon": "",
		"attacker_health": 61,
		"assister_weapon": "",
		"victim_serial": 4359,
		"assister_armor": 0,
		"assister_deaths": 2,
		"penetrated": 0,
		"assister_health": 0,
		"attacker_deaths": 0,
		"assister_serial": 3845,
		"victim_deaths": 2,
		"dominated": 0,
		"assiter_name": "Cory",
		"victim_name": "Ivan",
		"victim_armor": 0,
		"attacker_name": "Vinny",
		"attacker_armor": 95,
		"attacker_serial": 5130,
		"weapon": "ak47",
		"revenge": 0
	}
}
```

### Example - Bots killing humans

In this example, 'patrick' is a real user (as evidenced by the `victim_steam_id`). Also, since the victim was a person, note the `latency`, `avg_loss` and `avg_choke` values for the upload and download side of their connection.

```json
{
	"event_type": "player_death",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169188.0472977",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
    "map": "de_dust2",
    "timestamp": 1533169188,
    "steam_server_id": 2409689,
		"headshot": false,
		"victim_weapon": "",
		"victim_client_time": 343.5828857421875,
		"victim_steam_id": "76561198826380494",
		"victim_name": "patrick",
		"victim_serial": 257,
		"attacker_deaths": 0,
		"victim_deaths": 1,
		"victim_armor": 0,
		"victim_avg_loss_up": 0.0,
		"victim_latency_down": 0.051481619477272034,
		"attacker_serial": 1542,
		"victim_ip": "172.14.55.13",
		"penetrated": 0,
		"victim_latency_up": 0.005086179822683334,
		"victim_avg_loss_down": 0.0,
		"victim_avg_choke_up": 0.6013933420181274,
		"attacker_health": 84,
		"victim_avg_choke_down": 0.0,
		"attacker_name": "Finn",
		"attacker_armor": 0,
		"weapon": "glock",
		"dominated": 0,
		"revenge": 0
	}
}
```

### Example - Humans killing Humans

```json
{
	"event_type": "player_death",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169188.0472977",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
    "map": "de_dust2",
    "timestamp": 1533169188,
    "steam_server_id": 2409689,
		"headshot": false,
		"victim_weapon": "",
		"victim_client_time": 343.5828857421875,
		"victim_steam_id": "76561198826380494",
		"victim_name": "patrick",
		"victim_serial": 257,
		"attacker_deaths": 0,
		"victim_deaths": 1,
		"victim_armor": 0,
		"victim_avg_loss_up": 0.0,
		"victim_latency_down": 0.051481619477272034,
		"attacker_serial": 1542,
		"victim_ip": "172.14.55.13",
		"penetrated": 0,
		"victim_latency_up": 0.005086179822683334,
		"victim_avg_loss_down": 0.0,
		"victim_avg_choke_up": 0.6013933420181274,
		"attacker_health": 84,
		"victim_avg_choke_down": 0.0,
		"attacker_name": "caerus",
    "attacker_steam_id": "12345678909876543",
    "attacker_client_time": 343.5828857421875,
    "attacker_ip": "83.24.43.132",
		"attacker_armor": 0,
		"weapon": "glock",
		"dominated": 0,
		"revenge": 0
	}
}
```

## `server_player_connect`

This event derives its data from the [`player_connect`](https://wiki.alliedmods.net/Generic_Source_Server_Events#player_connect) event.

```json
{
	"event_type": "player_connect",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169212.945842",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
		"bot": 0,
		"timestamp": 1533169212,
		"name": "patrick",
		"address": "",
		"user_id": 12,
		"network_id": "STEAM_1:0:433057383",
		"map": "de_dust2",
		"steam_server_id": 2409689
	}
}
```

## `server_player_info`

This event derives its data from the [`player_info`](https://wiki.alliedmods.net/Generic_Source_Server_Events#player_info) event.

This is a mostly useless event... we can ignore it and let it just log to s3 for now.

## `server_player_disconnect`

This event derives its data from the [`player_disconnect`](https://wiki.alliedmods.net/Generic_Source_Server_Events#player_disconnect) event.


```json
{
	"event_type": "player_disconnect",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169199.4689293",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
    "map": "de_dust2",
    "steam_server_id": 2409689,
    "timestamp": 1533169199,
		"bot": 0,
		"network_id": "STEAM_1:0:433057383",
		"user_id": 2,
		"reason": "Disconnect"
	}
}
```

## `server_player_activate`

This event derives its data from the [`player_activate`](https://wiki.alliedmods.net/Generic_Source_Server_Events#player_activate) event.


```json
{
	"event_type": "player_activate",
	"game": {
		"id": "730",
		"name": "cs:go",
		"type": "fps",
		"platform": "steam"
	},
	"server": {
		"ip": "34.218.255.44",
		"mode": "1",
		"type": "0",
		"timestamp": "1533169226.8073971",
		"name": "ChallengerVault.com Telemetry Test"
	},
	"payload": {
		"user_id": 12,
		"user_steam_id": "76561198826380494",
		"steam_server_id": 2409689
	}
}
```
