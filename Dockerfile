ARG CROSS_HOST

FROM --platform=linux/amd64 abcfy2/muslcc-toolchain-ubuntu:${CROSS_HOST} as BUILD

ENV CROSS_HOST=${CROSS_HOST}

ARG QBEE_VERSION=release-4.6.6.10 \
    LIBTORRENT_BRANCH=RC_2_0 \
    UPX_VERSION=4.2.4

SHELL ["/bin/bash", "-c"] 

# add qbitorrent-ee
RUN --mount=type=cache,target=/usr/src/ \
    --mount=type=cache,target=/var/cache/apt/ \
    apt-get update && \
    apt-get -y install git xz-utils curl unzip python3-venv && \
    curl -fLo /tmp/upx.tar.xz \
        https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-$(dpkg --print-architecture)_linux.tar.xz && \
    tar xvf /tmp/upx.tar.xz -C /usr/bin upx-${UPX_VERSION}-$(dpkg --print-architecture)_linux/upx  --strip-components 1 && \    
    git clone -b ${QBEE_VERSION} https://github.com/c0re100/qBittorrent-Enhanced-Edition.git /qbee && \
    cd /qbee && \
    sed -i 's/qBittorrent Enhanced/qBittorrent/g' src/base/bittorrent/sessionimpl.cpp && \
    sed -i 's/#define QBT_VERSION_BUILD [[:digit:]]\+/#define QBT_VERSION_BUILD 0/g' src/base/version.h.in && \
    sed -i 's/LIBTORRENT_BRANCH=".*"/LIBTORRENT_BRANCH="${LIBTORRENT_BRANCH}"/g' .github/workflows/cross_build.sh && \
    # static qt version
    sed -i -e 's/qt_major_ver=".*"/qt_major_ver="6.6"/g' \
        -e 's/qt_ver=".*"/qt_ver="6.6.3"/g' \
        .github/workflows/cross_build.sh && \
    # setup venv
    python3 -m venv /tmp/qbee-build && \
        source /tmp/qbee-build/bin/activate && \
        pip install requests semantic_version lxml && \
    .github/workflows/cross_build.sh; \
    upx /tmp/qbittorrent-nox && \
    chmod +x /tmp/qbittorrent-nox

FROM --platform=$TARGETPLATFORM ghcr.io/linuxserver/unrar:latest as unrar

FROM --platform=$TARGETPLATFORM ghcr.io/linuxserver/baseimage-alpine:edge

ARG LINUX_SERVER_QB_VERSION=4.6.6-r0-ls348 \
    QB_MATUI_VERSION=1.16.4 \
    QB_WEB_VERSION=nightly-20230513 \
    VUE_TORRENT_VERSION=2.12.0

# environment settings
ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache \
        icu-libs \
        p7zip \
        python3 \
        qt6-qtbase-sqlite && \
    mkdir /qbt && \
    echo "***** install qbitorrent-cli ****" && \
    case $(arch) in \
        'x86_64') export QBT_ARCH=x64 ;; \
        'aarch64') export QBT_ARCH=arm64 ;; \
        *) echo "unknown arch: $(arch)" && exit 1;;  \
    esac && \
    if [ -z ${QBT_CLI_VERSION+x} ]; then \
        QBT_CLI_VERSION=$(curl -sfL "https://api.github.com/repos/fedarovich/qbittorrent-cli/releases/latest" \
            | jq -r '. | .tag_name'); \
    fi && \
    curl -fLo/tmp/qbt.tar.gz \
        "https://github.com/fedarovich/qbittorrent-cli/releases/download/${QBT_CLI_VERSION}/qbt-linux-alpine-${QBT_ARCH}-${QBT_CLI_VERSION#v}.tar.gz" && \
    tar xf /tmp/qbt.tar.gz -C /qbt && \
    echo "***** install linux qbitorrent rootfs ****" && \
    curl -fLo /tmp/rootfs.tar.gz \
        "https://github.com/linuxserver/docker-qbittorrent/archive/refs/tags/${LINUX_SERVER_QB_VERSION}.tar.gz" && \
    tar xf /tmp/rootfs.tar.gz -C / docker-qbittorrent-${LINUX_SERVER_QB_VERSION}/root/ --strip-components 2 && \
    mkdir -p /srv/www && \
    echo "***** install qbit-matUI ****" && \
    if [ -n ${QB_MATUI_VERSION} ]; then \
        curl -fLo /tmp/qbit-matUI.zip \
            https://github.com/bill-ahmed/qbit-matUI/releases/download/v${QB_MATUI_VERSION}/qbit-matUI_Unix_${QB_MATUI_VERSION}.zip && \
        unzip /tmp/qbit-matUI.zip -d /tmp && \
        mv /tmp/qbit-matUI_Unix_${QB_MATUI_VERSION} /tmp/qbit-matUI && \
        mv /tmp/qbit-matUI /srv/www; \
    fi && \
    echo "***** install qb-web ****" && \
    if [ -n ${QB_WEB_VERSION} ]; then \
        curl -fLo /tmp/qb-web.zip \
            https://github.com/CzBiX/qb-web/releases/download/${QB_WEB_VERSION}/qb-web-${QB_WEB_VERSION}.zip && \
        unzip /tmp/qb-web.zip -d /tmp && \
        mv /tmp/dist /tmp/qb-web && \
        mv /tmp/qb-web /srv/www; \
    fi && \
    echo "***** install VueTorrent ****" && \
    if [ -n ${VUE_TORRENT_VERSION} ]; then \
        curl -fLo /tmp/vuetorrent.zip \
            https://github.com/VueTorrent/VueTorrent/releases/download/v${VUE_TORRENT_VERSION}/vuetorrent.zip && \
        unzip /tmp/vuetorrent.zip -d /tmp && \
        mv /tmp/vuetorrent /srv/www; \
    fi && \
    echo "**** cleanup ****" && \
    rm -rf /root/.cache /tmp/*

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# add qbittorrent
COPY --from=BUILD /tmp/qbittorrent-nox /usr/bin/qbittorrent-nox

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config
