# Pi-Hole, Unbound and Squid installation script for new Linux installations.

A simple script to help install Pi-Hole, Unbound and Squid on new Linux installations.

    git clone https://github.com/siafulinux/Pi-Hole-Unbound-and-Squid-install-script.git
    
### Make sure to edit the top section to reflect your specific settings...

    nano install_pihole_unbound_squid.sh

    # Define variables
    TIMEZONE="America/New_York"
    PIHOLE_PASSWORD="Password"
    SERVER_IP="192.168.0.*"
    DOMAIN="website.com"
