#FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic
FROM ubuntu:22.04

USER root
WORKDIR /app

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
  XDG_CONFIG_HOME="/config" \
  PORT=9117

RUN \
  echo "**** install packages ****" &&
  apt update &&
  apt install -y \
    unzip \
    jq \
    curl \
    ffmpeg \
    aria2 \
    libssl1.0 \
    python3 \
    python3-pip \
    php-curl \
    php-json \
    php-cli \
    php-mbstring \
    wget &&
  echo "**** install jackett ****" &&
  mkdir -p \
    /app/Jackett &&
  if [ -z ${JACKETT_RELEASE+x} ]; then
    JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" |
      jq -r .tag_name)
  fi &&
  curl -o \
    /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxAMDx64.tar.gz" &&
  tar xf \
    /tmp/jacket.tar.gz -C \
    /app/Jackett --strip-components=1 &&
  echo "**** fix for host id mapping error ****" &&
  chown -R root:root /app/Jackett &&
  echo "**** save docker image version ****" &&
  echo "${VERSION}" >/etc/docker-image &&
  echo "**** cleanup ****" &&
  apt clean &&
  apt remove apache2 -y &&
  pip3 install yt-dlp &&
  pip3 install streamlink

RUN wget -O libicu.deb https://ftp.up.pt/ubuntu/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.2_amd64.deb && chmod 777 libicu.deb
RUN dpkg -i ./libicu.deb
RUN rm *.deb

COPY ./config /config
RUN mkdir /data
RUN mkdir /cache
RUN chmod 777 -R /data
RUN chmod 777 -R /cache
COPY m.zip /config/Jackett/index.zip
RUN cd /config/Jackett && unzip index.zip && rm index.zip

CMD exec /app/Jackett/jackett -p $PORT
