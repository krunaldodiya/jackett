# Use a base image with Ubuntu
FROM ubuntu:22.04

# Change working directory
WORKDIR /app

# Set environment variables
ENV XDG_DATA_HOME="/config"
ENV XDG_CONFIG_HOME="/config"

# Install necessary packages and dependencies
RUN apt update
RUN apt install -y curl libicu-dev

# Download and install Jackett binary
RUN curl -o jackett.tar.gz -L https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz
RUN tar xf jackett.tar.gz -C .
RUN rm jackett.tar.gz

# Expose the Jackett port
EXPOSE 9117

# # Set the command to run Jackett
CMD ["Jackett/jackett", "-p", "9117"]
