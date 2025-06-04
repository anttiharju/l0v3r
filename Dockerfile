FROM golang:1.24.3-alpine3.21 AS builder

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 go build -ldflags "-s -w -buildid=" -trimpath -o l0v

FROM haproxy:3.2.0-alpine3.21

# Switch to root user for installation
USER root

WORKDIR /app

# Install OpenSSH server
RUN apk add --no-cache openssh shadow socat && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

# Create directory for HAProxy socket
RUN mkdir -p /var/run/haproxy && \
    chmod 755 /var/run/haproxy

# Add a user for SSH access
RUN useradd -m -s /bin/sh sshuser && \
    echo "sshuser:password" | chpasswd

# Copy your application
COPY --from=builder /build/l0v /app/l0v

# Make the binary executable and available to all users
RUN chmod +x /app/l0v && \
    ln -sf /app/l0v /usr/local/bin/l0v

# Create entrypoint script properly with actual newlines
RUN printf '#!/bin/sh\n/usr/sbin/sshd -D &\nexec "$@"\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    cat /entrypoint.sh  # Verify the file was created correctly

# Add environment variables to both profiles
RUN echo 'export PATH="/app:$PATH"' >> /etc/profile && \
    echo 'export PATH="/app:$PATH"' >> /home/sshuser/.profile

# Switch back to haproxy user for running the service
# Comment out the line below if HAProxy needs to run as root
# USER haproxy

ENTRYPOINT ["/entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
