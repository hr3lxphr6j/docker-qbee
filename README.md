# Docker-QBEE

[中文说明](https://github.com/hr3lxphr6j/docker-qbee/blob/main/README.zh_cn.md)

A docker image for [qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition), but using the original User-Agent (which used by qBittorrent) for compatibility with PT sites.


## Components

- [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent) (base image)
- [c0re100/qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition) (compressed with UPX).
- [fedarovich/qbittorrent-cli](https://api.github.com/repos/fedarovich/qbittorrent-cli)
- [bill-ahmed/qbit-matUI](https://github.com/bill-ahmed/qbit-matUI)
- [CzBiX/qb-web](https://github.com/CzBiX/qb-web)
- [VueTorrent/VueTorrent](https://github.com/VueTorrent/VueTorrent)


## Use

> All parameters and behaviors are consistent with the [linuxserver/qbittorrent](https://github.com/linuxserver/docker-qbittorrent), please refer to the [documentation](https://hub.docker.com/r/linuxserver/qbittorrent).

- docker cli
    ```bash
    docker run -d \
    --name=qbittorrent \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Etc/UTC \
    -e WEBUI_PORT=8080 \
    -e TORRENTING_PORT=6881 \
    -p 8080:8080 \
    -p 6881:6881 \
    -p 6881:6881/udp \
    -v /path/to/qbittorrent/appdata:/config \
    -v /path/to/downloads:/downloads \
    --restart unless-stopped \
    ghcr.io/hr3lxphr6j/docker-qbee:latest
    ```
- docker-compose

    ```yaml
    ---
    services:
    qbittorrent:
        image: ghcr.io/hr3lxphr6j/docker-qbee:latest
        container_name: qbittorrent
        environment:
        - PUID=1000
        - PGID=1000
        - TZ=Etc/UTC
        - WEBUI_PORT=8080
        - TORRENTING_PORT=6881
        volumes:
        - /path/to/qbittorrent/appdata:/config
        - /path/to/downloads:/downloads
        ports:
        - 8080:8080
        - 6881:6881
        - 6881:6881/udp
        restart: unless-stopped
    ```


## Parameters (same as [linuxserver/qbittorrent](https://github.com/linuxserver/docker-qbittorrent))

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | WebUI |
| `-p 6881` | tcp connection port |
| `-p 6881/udp` | udp connection port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e WEBUI_PORT=8080` | for changing the port of the web UI, see below for explanation |
| `-e TORRENTING_PORT=6881` | for changing the port of tcp/udp connection, see below for explanation |
| `-v /config` | Contains all relevant configuration files. |
| `-v /downloads` | Location of downloads on disk. |


## WebUI

You can use other WebUI by setting the following.
>`Options` -> `Web UI` -> `Use alternative Web UI` -> `Files location`

| WebUI | Path |
| ---- | --- |
| [bill-ahmed/qbit-matUI](https://github.com/bill-ahmed/qbit-matUI) | `/srv/www/qbit-matUI` |
| [CzBiX/qb-web](https://github.com/CzBiX/qb-web) | `/srv/www/qb-web` |
| [VueTorrent/VueTorrent](https://github.com/VueTorrent/VueTorrent) | `/srv/www/vuetorrent` |


## Supported Architectures

| Architecture | Available |
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |