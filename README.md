# CSGO Dedicated Server

What's here:

* Docker build for images
* configuration files


## What goes into the setup for a server:

* a pre-built container running the CS:GO server as defined by the docker build in the `gameserver` directory of this repository
* a `start.sh` script - separate for dev and prod:
	* `start_dev.sh`
	* `start_prod.sh`
* a docker env file - one per machine with unique naming and configurations
	* in the `_docker-compose.env` directory


## How do I?

### change the configuration of a single gameserver

* find the appropriate environment file in `_docker-compose.env`
* update the explicit settings that are called out
* add any additional commands for the `srcds_run` command to the `SRCDS_EXTRA_ARGS` environment variable, add it if it's not present

### build a new image for the CS:GO server

* if no code changes:
 	* go to [circleci](https://circleci.com/gh/challengerinteractive/workflows/csgo/tree/master)
	* find the latest `build_and_publish` workflow
	* rerun the workflow from the beginning
* if code changes:
	* commit code changes to `master` branch
	* so long as the string `[skip ci]` is not in the commit message, circleci will build a new image

### How do I redeploy the gameserver container?

A 'redeploy' is the process of getting the latest game server docker image, removing the current running container and restarting with the new image. If you just need to restart (i.e. to try to manually run the steamcmd update process) then you might want to try asking how you reset a running server.

* servers are redeployable in groups - dev or prod only (for now)
* go to [circleci](https://circleci.com/gh/challengerinteractive/workflows/csgo/tree/master)
* find the latest 'master/operations-tasks' workflow
* reset/rerun the workflow if it's been run before
* approve the appropriate job (dev or prod) and it will run the reset workflow
  * `approve_redeploy_dev`
	* `APPROVE_REDEPLOY_PROD`

### How do I reset a running server

A 'reset' is the process of stopping and restarting assets that are alredy in place. If you want to redeploy (get the latest image) you want to ask the question about how you redeploy things.

* servers are resettable in groups - dev or prod only (for now)
* go to [circleci](https://circleci.com/gh/challengerinteractive/workflows/csgo/tree/master)
* find the latest 'master/operations-tasks' workflow
* reset/rerun the workflow if it's been run before
* approve the appropriate job (dev or prod) and it will run the reset workflow
  * `approve_reset_dev`
	* `APPROVE_RESET_PROD`

### How do I add more servers

* Create a file in `_docker-compose.env` for it...
	* you'll need to get a steam key for the server from [here](https://steamcommunity.com/dev/managegameservers)
	* name it appropriately
	* set up the game config (type/mode)
* launch an AWS ec2 instance (ubuntu 16.04) with the bootstrap script [ubuntu-ec2-bootstrap.sh](ubuntu-ec2-bootstrap.sh) or run that script after launch
	* make sure it's launched with the appropriate key (dev/prod)
	* make sure it's in a public subnet and that the security group assigned has port 27000-27030 tcp and udp ingress enabled
	* if unsure check with techops
	* if new region, import existing key (publickey) into ec2 before launching
	* dev and prod keys are available in 1password:
		* [production key](https://challenger.1password.com/vaults/zcubfb473pr2zbubvtl6y72g5i/allitems/33efxa5munbexprp7j6orlvc7e)
		* [dev key](https://challenger.1password.com/vaults/zcubfb473pr2zbubvtl6y72g5i/allitems/eslao72dsogpugyufpzkmca7su)
* add the new server to the list (as appopriate) to the dev and prod scripts in this repo
	* to the `run_redeploy_{env}.sh` and `run_redeploy_{env}.sh` files:
		* for each step, add the new server following the same pattern
		* the only step here that is unique per sever in any of these files is copying the env file created above
* commit all the changes to github and get it to master... let circleci do it's job
* NOTE: first deployments may take a little extra time (2-4 min) to build resources locally on machine (in docker and compose)... this is normal
