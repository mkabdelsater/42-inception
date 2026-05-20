FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download cAdvisor binary
# Using v0.49.1 as a stable version
RUN curl -L https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 -o /usr/bin/cadvisor && \
    chmod +x /usr/bin/cadvisor

EXPOSE 8080

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr", "--url_base_prefix=/cadvisor"]
