# Use a base image with Ubuntu
FROM ubuntu:22.04

# Set environment variables
ENV XDG_DATA_HOME="/config" \
  XDG_CONFIG_HOME="/config" \
  PORT=9117

# Install necessary packages and dependencies
RUN apt update && apt install -y \
  curl \
  libssl1.0 &&
  apt-get clean &&
  rm -rf /var/lib/apt/lists/*

# Download and install Jackett binary
RUN curl -o /app/jackett.tar.gz -L \
  https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz &&
  tar xf /app/jackett.tar.gz -C /app &&
  rm /app/jackett.tar.gz

# Change working directory
WORKDIR /app

# Expose the Jackett port
EXPOSE $PORT

# Set the command to run Jackett
CMD ["/app/Jackett", "-p", "$PORT"]
