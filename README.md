# valheim-google-run
Repo to run Valheim in a docker container on Google Run

### GCP Shell Commands
```bash
mkdir -p $HOME/valheim-server/config/worlds $HOME/valheim-server/data
# copy existing world
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
