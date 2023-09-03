# Use a base image with Ubuntu 22.04
FROM ubuntu:22.04

# Create a non-root user 'jackett'
RUN useradd -r -s /sbin/nologin jackett

# Change working directory
WORKDIR /app

# Set environment variables
ENV XDG_DATA_HOME="/config"
ENV XDG_CONFIG_HOME="/config"
ENV PORT="9117"

# Install necessary packages and dependencies
RUN apt update
RUN apt install -y curl libicu-dev

# Download and install Jackett binary
RUN curl -o jackett.tar.gz -L https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz
RUN tar xf jackett.tar.gz -C .
RUN rm jackett.tar.gz

# Change ownership to the 'jackett' user
RUN chown -R jackett:jackett ./Jackett # Use relative path

# Expose the Jackett port (use the environment variable)
EXPOSE $PORT

# Set the command to run Jackett as the 'jackett' user with the dynamic port
USER jackett
CMD ["Jackett/jackett", "-p", "$PORT"]
