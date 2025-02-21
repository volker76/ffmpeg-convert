# Use Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04

# Update package lists again and install FFmpeg
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge --auto-remove && \
    apt-get clean
    

# Set the working directory to /app
WORKDIR /app

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Configure entrypoint with shell script
ENTRYPOINT ["/entrypoint.sh"]