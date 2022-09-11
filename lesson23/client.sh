#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
DISTRO="$(lsb_release -ds)"
CLIENT_DIR=/etc/openvpn/client
sudo rm -rf ${CLIENT_DIR}/*

if [[ "${DISTRO}" == '"Arch Linux"' ]] ; then
  sudo cp /usr/share/openvpn/examples/client.conf ${CLIENT_DIR}
else
  sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ${CLIENT_DIR}
fi

CONF="${CLIENT_DIR}/client.conf"
DEVICE=$(sudo ip route show default | grep -oP '(?<=(dev\s))(.+?\b)')
IP=$(ip -o -4 addr | awk '$2 ~ /'$DEVICE'/{print $4}' | cut -d '/' -f 1 | head -n1)
sudo sed -i '/^remote /s/.*/remote '$IP' 1194/' "${CONF}"
sudo sed -i -E '/^;(user|group)/{s/^;//}' "${CONF}"
sudo sed -i -E '/^(ca ca\.crt|cert client\.crt|key client\.key|tls-auth)/s/^/;/' "${CONF}"
sudo sed -i '/^cipher/{s/^/# /;s/$/\ncipher AES-256-GCM\nauth SHA256/}' "${CONF}"
echo 'key-direction 1' | sudo tee -a "${CONF}" > /dev/null
echo '; script-security 2
; up /etc/openvpn/update-resolv-conf
; down /etc/openvpn/update-resolv-conf' | sudo tee -a "${CONF}" > /dev/null
echo 'script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .' | sudo tee -a "${CONF}" > /dev/null
