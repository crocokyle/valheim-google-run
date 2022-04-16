# GCP One-liner
### Instance
```bash
gcloud compute instances create-with-container valheim-4gb-container-1 --project=valheim-808 --zone=us-central1-a --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=860324119380-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=projects/cos-cloud/global/images/cos-stable-97-16919-29-9 --boot-disk-size=10GB --boot-disk-type=pd-balanced --boot-disk-device-name=valheim-4gb-container --container-image=gcr.io/valheim-808/llosche/valheim-server --container-restart-policy=always --container-arg=--name\ valheim-server --container-arg=--cap-add=sys_nice --container-arg=--stop-timeout\ 120 --container-arg=-p\ 2456-2457:2456-2457/udp --container-env=SERVER_NAME=ServerMcServie,WORLD_NAME=ElmosWorld,SERVER_PASS=titties --container-mount-host-path=host-path=\$HOME/valheim-server/config,mode=rw,mount-path=/config --container-mount-host-path=host-path=\$HOME/valheim-server/data,mode=rw,mount-path=/opt/valheim --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=container-vm=cos-stable-97-16919-29-9
```
### Firewall Rules
```bash
gcloud compute --project=valheim-808 firewall-rules create valheim-udp --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=udp:2456-2457 --source-ranges=0.0.0.0/0
```

# valheim-google-run
Repo to run Valheim in a docker container on Google Run. Adapted from https://github.com/lloesche/valheim-server-docker#valheimplus

## GCP Shell Commands
#### Create initial directories
```bash
mkdir -p $HOME/valheim-server/config/worlds $HOME/valheim-server/data
```
#### Start the server
```bash
docker run -d \
    --name valheim-server \
    --cap-add=sys_nice \
    --stop-timeout 120 \
    -p 2456-2457:2456-2457/udp \
    -v $HOME/valheim-server/config:/config \
    -v $HOME/valheim-server/data:/opt/valheim \
    -e SERVER_NAME="ServerMcServie" \
    -e WORLD_NAME="ElmosWorld" \
    -e SERVER_PASS="titties" \
    lloesche/valheim-server
```

## GCP Networking
```dockerfile
EXPOSE 2456-2457/udp
EXPOSE 9001/tcp
EXPOSE 80/tcp
```

## Migrating existing servers

### Windows:
- Copy the files from `C:\Users\<username>\AppData\LocalLow\IronGate\Valheim\worlds` to `$HOME/valheim-server/config/worlds`
- Run the image with the `$HOME/vaheim-server/config` volume mounted to `/config` in the container.
---
**NOTE**

*The container directory /opt/valheim contains the downloaded server. It can optionally be volume mounted to avoid having to download the server on each fresh start.*

---

## Environment Variables

All variable names and values are case-sensitive!


|Name|Default|Purpose|
|--- |--- |--- |
|SERVER_NAME|My Server|Name that will be shown in the server browser|
|SERVER_PORT|2456|UDP start port that the server will listen on|
|WORLD_NAME|Dedicated|Name of the world without .db/.fwl file extension|
|SERVER_PASS|secret|Password for logging into the server - min. 5 characters!|
|SERVER_PUBLIC|true|Whether the server should be listed in the server browser (true) or not (false)|
|SERVER_ARGS||Additional Valheim server CLI arguments|
|ADMINLIST_IDS||Space separated list of admin SteamIDs. Overrides any existing adminlist.txt entries!|
|BANNEDLIST_IDS||Space separated list of banned SteamIDs. Overrides any existing bannedlist.txt entries!|
|PERMITTEDLIST_IDS||Space separated list of whitelisted SteamIDs. Overrides any existing permittedlist.txt entries!|
|UPDATE_CRON|*/15 * * * *|Cron schedule for update checks (disabled if set to an empty string or if the legacy UPDATE_INTERVAL is set)|
|UPDATE_IF_IDLE|true|Only run update check if no players are connected to the server (true or false)|
|RESTART_CRON|0 5 * * *|Cron schedule for server restarts (disabled if set to an empty string)|
|RESTART_IF_IDLE|true|Only run daily restart if no players are connected to the server (true or false)|
|TZ|Etc/UTC|Container time zone|
|BACKUPS|true|Whether the server should create periodic backups (true or false)|
|BACKUPS_CRON|0 * * * *|Cron schedule for world backups (disabled if set to an empty string or if the legacy BACKUPS_INTERVAL is set)|
|BACKUPS_DIRECTORY|/config/backups|Path to the backups directory|
|BACKUPS_MAX_AGE|3|Age in days after which old backups are flushed|
|BACKUPS_MAX_COUNT|0|Maximum number of backups kept, 0 means infinity|
|BACKUPS_IF_IDLE|true|Backup even when no players have been connected for a while|
|BACKUPS_IDLE_GRACE_PERIOD|3600|Grace period in seconds after the last player has disconnected in which we will still create backups when BACKUPS_IF_IDLE=false|
|PERMISSIONS_UMASK|022|Umask to use for backups, config files and directories|
|STEAMCMD_ARGS|validate|Additional steamcmd CLI arguments|
|VALHEIM_PLUS|false|Whether ValheimPlus mod should be loaded (config in /config/valheimplus, additional plugins in /config/valheimplus/plugins). Can not be used together with BEPINEX.|
|BEPINEX|false|Whether BepInExPack Valheim mod should be loaded (config in /config/bepinex, plugins in /config/bepinex/plugins). Can not be used together with VALHEIM_PLUS.|
|SUPERVISOR_HTTP|false|Turn on supervisor's http server|
|SUPERVISOR_HTTP_PORT|9001|Set supervisor's http server port|
|SUPERVISOR_HTTP_USER|admin|Supervisor http server username|
|SUPERVISOR_HTTP_PASS||Supervisor http server password|
|STATUS_HTTP|false|Turn on the status http server. Only useful on public servers (SERVER_PUBLIC=true).|
|STATUS_HTTP_PORT|80|Status http server tcp port|
|STATUS_HTTP_CONF|/config/httpd.conf|Path to the busybox httpd config|
|STATUS_HTTP_HTDOCS|/opt/valheim/htdocs|Path to the status httpd htdocs where status.json is written|
|SYSLOG_REMOTE_HOST||Remote syslog host or IP to send logs to|
|SYSLOG_REMOTE_PORT|514|Remote syslog UDP port to send logs to|
|SYSLOG_REMOTE_AND_LOCAL|true|When sending logs to a remote syslog server also log local|
|PUID|0|UID to run valheim-server as|
|PGID|0|GID to run valheim-server as|

---

## Mods

## Mod config from Environment Variables
Mod config can be specified in environment variables using the syntax `<prefix>_<section>_<variable>=<value>`.

**Predefined prefix list**
| Prefix | Mod | File |
|----------|----------|----------|
| `VPCFG` | ValheimPlus | `/config/valheimplus/valheim_plus.cfg` |
| `BEPINEXCFG` | BepInEx | `/config/valheimplus/BepInEx.cfg` or `/config/bepinex/BepInEx.cfg` depending on whether `VALHEIM_PLUS=true` or `BEPINEX=true` |


**Translation table**  
Some characters that are allowed as section names in the config files are not allowed as environment variable names. They can be encoded using the following translation table.
| Variable name string | Replacement |
|----------|----------|
| `_DOT_` | `.` |
| `_HYPHEN_` | `-` |
| `_UNDERSCORE_` | `_` |
| `_PLUS_` | `+` |

Example:
```
-e VALHEIM_PLUS=true \
-e VPCFG_Server_enabled=true \
-e VPCFG_Server_enforceMod=false \
-e VPCFG_Server_dataRate=500 \
-e BEPINEXCFG_Logging_DOT_Console_Enabled=true
```

turns into `/config/valheimplus/valheim_plus.cfg`
```
[Server]
enabled=true
enforceMod=false
dataRate=500
```

and `/config/valheimplus/BepInEx.cfg`
```
[Logging.Console]
Enabled=true
```

All existing configuration in those files is retained and a backup of the old config is created as e.g. `/config/valheimplus/valheim_plus.cfg.old` before writing the new config file.

You could generate your own custom plugin config from environment variables using [the `POST_BEPINEX_CONFIG_HOOK` event hook](#event-hooks) and [`env2cfg`](https://github.com/lloesche/valheim-server-docker/tree/main/env2cfg).

