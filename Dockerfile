FROM ubuntu:22.04

RUN useradd -r -s /sbin/nologin jackett

WORKDIR /app

RUN mkdir /app/config

RUN chown -R jackett:jackett /app/config

ENV XDG_DATA_HOME="/app/config"
ENV XDG_CONFIG_HOME="/app/config"

RUN apt update
RUN apt install -y curl libicu-dev gosu
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

RUN curl -o jackett.tar.gz -L https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz
RUN tar xf jackett.tar.gz -C /app
RUN rm jackett.tar.gz

RUN chown -R jackett:jackett /app/Jackett

EXPOSE 9117

USER jackett

CMD ["/app/Jackett/jackett", "-p", "9117"]
