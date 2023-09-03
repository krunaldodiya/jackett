# Use the base image with Ubuntu 22.04
FROM ubuntu:22.04

# Set the working directory
WORKDIR /app

# Set version labels and maintainer
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
  XDG_CONFIG_HOME="/config" \
  PORT=9117

# Install necessary packages and dependencies
RUN apt update && apt install -y \
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
    wget \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install yt-dlp \
 && pip3 install streamlink

# Install libicu60 package from a specific source
RUN wget -O libicu.deb https://ftp.up.pt/ubuntu/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.2_amd64.deb && \
    dpkg -i ./libicu.deb && \
    rm libicu.deb

# Copy configuration files
COPY ./config /config
RUN mkdir /data
RUN mkdir /cache
RUN chmod 777 -R /data
RUN chmod 777 -R /cache

# Copy and unzip index.zip
COPY m.zip /config/Jackett/index.zip
RUN cd /config/Jackett && unzip index.zip && rm index.zip

# Install Jackett
RUN mkdir -p /app/Jackett
RUN if [ -z ${JACKETT_RELEASE+x} ]; then \
      JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" | jq -r .tag_name); \
    fi && \
    curl -o /tmp/jacket.tar.gz -L "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxAMDx64.tar.gz" && \
    tar xf /tmp/jacket.tar.gz -C /app/Jackett --strip-components=1

# Change ownership of Jackett files
RUN chown -R root:root /app/Jackett

# Create a file to save Docker image version
RUN echo "${VERSION}" >/etc/docker-image

# Set the command to run Jackett
CMD exec /app/Jackett/jackett -p $PORT
