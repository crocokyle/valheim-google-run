# valheim-google-run
Repo to run Valheim in a docker container on Google Run

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
    -e SERVER_NAME="My Server" \
    -e WORLD_NAME="NewWorld" \
    -e SERVER_PASS="password" \
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
