#!/bin/bash
echo 'net.ipv4.ip_forward = 1' | sudo tee /usr/lib/sysctl.d/99-forwarding.conf > /dev/null
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null

DEVICE=$(sudo ip route show default | grep -oP '(?<=(dev\s))(.+?\b)')
if [ -f /etc/ufw/before.rules.bak ] ; then
  sudo cp /etc/ufw/before.rules.bak /etc/ufw/before.rules
fi
cat << EOF | (sudo head -n10 /etc/ufw/before.rules ; cat - ; sudo sed -n '10,$p' /etc/ufw/before.rules ) | sudo tee /etc/ufw/bef
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to ${DEVICE} (change to the interface you discovered!)
-A POSTROUTING -s 10.8.0.0/8 -o ${DEVICE} -j MASQUERADE
COMMIT
# END OPENVPN RULES
EOF
if [ ! -f /etc/ufw/before.rules.bak ] ; then
  sudo cp /etc/ufw/before.rules /etc/ufw/before.rules.bak
fi
sudo mv /etc/ufw/before.rules.new /etc/ufw/before.rules
sudo sed -i '/^DEFAULT_FORWARD_POLICY/s/DROP/ACCEPT/' /etc/default/ufw
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH
sudo ufw disable
yes | sudo ufw enable
