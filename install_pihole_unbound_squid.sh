#!/bin/bash

# Define variables
TIMEZONE="America/New_York"
PIHOLE_PASSWORD="Password"
SERVER_IP="192.168.0.100"
DOMAIN="siafunet.xyz"
DOCKER_COMPOSE_FILE="docker-compose.yml"
UNBOUND_CONF_DIR="unbound"
SQUID_CONF_DIR="squid-conf"
SQUID_CACHE_DIR="squid-cache"
PIHOLE_VOL_DIR="etc-pihole"
DNSMASQ_VOL_DIR="etc-dnsmasq.d"

# Check if docker-compose is installed
if ! command -v docker-compose &>/dev/null; then
    echo "Installing docker-compose..."
    sudo apt update && sudo apt install -y docker-compose
fi

# Create necessary directories
mkdir -p $UNBOUND_CONF_DIR $SQUID_CONF_DIR $SQUID_CACHE_DIR $PIHOLE_VOL_DIR $DNSMASQ_VOL_DIR

# Create Docker Compose file
cat <<EOL > $DOCKER_COMPOSE_FILE
version: "3"
services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    environment:
      - TZ=$TIMEZONE
      - WEBPASSWORD=$PIHOLE_PASSWORD
      - VIRTUAL_HOST=$DOMAIN
      - PIHOLE_DNS_=$SERVER_IP
      - DNS1=127.0.0.1#5335
      - DNS2=127.0.0.1#5335
      - WEB_PORT=8080
    volumes:
      - ./$PIHOLE_VOL_DIR:/etc/pihole
      - ./$DNSMASQ_VOL_DIR:/etc/dnsmasq.d
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8080:80/tcp"
      - "443:443/tcp"
    cap_add:
      - NET_ADMIN
    restart: unless-stopped

  unbound:
    image: mvance/unbound:latest
    container_name: unbound
    volumes:
      - ./$UNBOUND_CONF_DIR:/etc/unbound
    networks:
      - default
    ports:
      - "5335:5335/tcp"
      - "5335:5335/udp"
    restart: unless-stopped
    command: ["-d", "-c", "/etc/unbound/unbound.conf"]

  squid:
    image: sameersbn/squid:latest
    container_name: squid
    ports:
      - "3128:3128"
    volumes:
      - ./$SQUID_CACHE_DIR:/var/spool/squid
      - ./$SQUID_CONF_DIR:/etc/squid
    restart: unless-stopped

networks:
  default:
    driver: bridge
EOL

# Create Unbound configuration file
cat <<EOL > $UNBOUND_CONF_DIR/unbound.conf
server:
  verbosity: 1
  interface: 0.0.0.0
  port: 5335
  do-ip4: yes
  do-ip6: no
  do-udp: yes
  do-tcp: yes
  root-hints: "/etc/unbound/root.hints"
  cache-min-ttl: 3600
  cache-max-ttl: 86400
  hide-identity: yes
  hide-version: yes
  harden-glue: yes
  harden-dnssec-stripped: yes
  trust-anchor-file: "/var/lib/unbound/root.key"
  auto-trust-anchor-file: "/var/lib/unbound/root.key"
EOL

# Download Unbound root hints
curl -o $UNBOUND_CONF_DIR/root.hints https://www.internic.net/domain/named.cache

# Create Squid configuration file
cat <<EOL > $SQUID_CONF_DIR/squid.conf
http_port 3128
visible_hostname squidproxy
cache_dir ufs /var/spool/squid 100 16 256
cache_mem 64 MB
access_log /var/log/squid/access.log squid
cache_log /var/log/squid/cache.log
pid_filename /var/run/squid.pid

acl localnet src 192.168.0.0/16  # Define your local network range
http_access allow localnet
http_access deny all
EOL

# Ensure proper ownership and permissions for Docker volumes
sudo chown -R 999:999 $PIHOLE_VOL_DIR $DNSMASQ_VOL_DIR

# Start Docker containers
docker-compose up -d

# Output success message
echo "Pi-hole, Unbound, and Squid proxy have been successfully set up."
echo "Access Pi-hole via http://$SERVER_IP:8080/admin with password '$PIHOLE_PASSWORD'."
