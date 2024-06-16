# Docker-QBEE

[English](https://github.com/hr3lxphr6j/docker-qbee/blob/main/README.md)

一个 [qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition) 的 docker image，使用原始的 User-Agent (qBittorrent的) 用于兼容 PT 站。


## 组件

- [linuxserver/docker-qbittorrent](https://github.com/linuxserver/docker-qbittorrent) (基础镜像)
- [c0re100/qBittorrent-Enhanced-Edition](https://github.com/c0re100/qBittorrent-Enhanced-Edition) (使用UPX压缩).
- [fedarovich/qbittorrent-cli](https://api.github.com/repos/fedarovich/qbittorrent-cli)
- [bill-ahmed/qbit-matUI](https://github.com/bill-ahmed/qbit-matUI)
- [CzBiX/qb-web](https://github.com/CzBiX/qb-web)
- [VueTorrent/VueTorrent](https://github.com/VueTorrent/VueTorrent)


## 使用

> 所有的参数和行为均与 [linuxserver/qbittorrent](https://github.com/linuxserver/docker-qbittorrent)一致，请参考这个[文档](https://hub.docker.com/r/linuxserver/qbittorrent)。

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


## 参数 (与 [linuxserver/qbittorrent](https://github.com/linuxserver/docker-qbittorrent) 一致)

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

通过更改如下的配置，你可以使用其他的 WebUI。
>`选项` -> `Web UI` -> `使用备用 Web UI` -> `文件路径`

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