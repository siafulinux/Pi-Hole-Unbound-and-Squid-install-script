# Pi-Hole, Unbound and Squid installation script for new Linux installations.

A simple script to help install Pi-Hole, Unbound and Squid on new Linux installations.

    git clone https://github.com/siafulinux/Pi-Hole-Unbound-and-Squid-install-script.git
    
### Make sure to edit your settings...

    cd Pi-Hole-Unbound-and-Squid-install-script
    nano install_pihole_unbound_squid.sh

    # Define variables
    TIMEZONE="America/New_York"
    PIHOLE_PASSWORD="Password"
    SERVER_IP="192.168.0.*"
    DOMAIN="website.com"

### Change your ports as needed...

    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8080:80/tcp"
      - "443:443/tcp"

### Run script

    chmod +x install_pihole_unbound_squid.sh
    ./install_pihole_unbound_squid.sh

And that should be it.
