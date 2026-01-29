FROM alpine:3.23

ARG S6_OVERLAY_VERSION=3.2.2.0

RUN apk update && \
    apk add --no-cache nginx openssh-server-pam openssh-sftp-server sudo && \
    # Generate SSH host keys
    ssh-keygen -A && \
    # Create necessary directories for s6-overlay services
    mkdir -p /etc/s6-overlay/s6-rc.d/nginx /etc/s6-overlay/s6-rc.d/sshd /etc/s6-overlay/s6-rc.d/user && \
    # Setup SSHD configuration
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
    # Install s6-overlay
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -O /tmp/noarch.tar.xz && \
    tar -C / -Jxpf /tmp/noarch.tar.xz && \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O /tmp/x86_64.tar.xz && \
    tar -C / -Jxpf /tmp/x86_64.tar.xz && \
    rm /tmp/*.tar.xz && \
    rm -rf $HOME/.cache

# Copy all setup
COPY root/ /

# Expose ports
EXPOSE 2222 8080

# Use s6-overlay init as entrypoint
ENTRYPOINT ["/init"]
