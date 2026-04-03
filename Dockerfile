FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ow-shell \
    knxd-tools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /sbin/nologin 1wire-lock

# Copy scripts
COPY 1-wire-lock.sh /usr/local/bin/1-wire-lock.sh
COPY liveness-probe.sh /usr/local/bin/liveness-probe.sh
RUN chmod +x /usr/local/bin/1-wire-lock.sh /usr/local/bin/liveness-probe.sh

# Set default environment variables
ENV ALLOWED_KEY_LIST=""
ENV KNX_LOCK_ADDRESS=""
ENV KNXD_ADDRESS="ip:localhost"
ENV OW_ADDRESS="localhost:4304"
ENV OW_BUS_ADDRESS=""
ENV SLEEP_AFTER="7"

# Run as non-root user
USER 1wire-lock

# Entrypoint
ENTRYPOINT ["/usr/local/bin/1-wire-lock.sh"]
