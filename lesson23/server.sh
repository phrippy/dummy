#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
EASYRSA_DIR="${SCRIPT_DIR}"/easy-rsa
PKI_DIR="${EASYRSA_DIR}"/pki
DISTRO="$(lsb_release -ds)"
SERVER_DIR=/etc/openvpn/server
CLIENT_DIR=/etc/openvpn/client
sudo rm -rf "${EASYRSA_DIR}" ${SERVER_DIR}/*
mkdir -p ${EASYRSA_DIR}
if [[ "${DISTRO}" == '"Arch Linux"' ]] ; then
#  sudo pacman -Sy --noconfirm openvpn easy-rsa ufw
  EASYRSA_COMMAND="easyrsa --pki-dir=${PKI_DIR}" 
  ln -s /etc/easy-rsa/* "${EASYRSA_DIR}"
  sudo cp -L "${EASYRSA_DIR}"/vars "${EASYRSA_DIR}"/vars.example 
  sudo rm "${EASYRSA_DIR}"/vars
else
#  sudo apt update
#  sudo apt -y install openvpn ufw
  EASYRSA_COMMAND="${EASYRSA_DIR}/easyrsa --pki-dir=${PKI_DIR}"
  ln -s /usr/share/easy-rsa/* "${EASYRSA_DIR}"
fi
sudo chown $USER "${EASYRSA_DIR}"
chmod 700 "${EASYRSA_DIR}"

# Инициализировать PKI (Public Key Infrastructure — Инфраструктура открытых ключей):
# created ${PKI_DIR}/
# created ${PKI_DIR}/private/
# created ${PKI_DIR}/reqs/
# created ${PKI_DIR}/openssl-easyrsa.cnf
# created ${PKI_DIR}/safessl-easyrsa.cnf
# created ${PKI_DIR}/vars.example
${EASYRSA_COMMAND} init-pki

#Перейти в каталог easyrsa3 и объявить для него переменные:
#cd $PKI_DIR
cat <<EOF | sudo cat "${EASYRSA_DIR}/vars.example" - > ${PKI_DIR}/vars
#cat <<EOF > /dev/null
#set_var EASYRSA_ALGO "ec"
#set_var EASYRSA_DIGEST "sha512"
#set_var EASYRSA_KEY_SIZE 512
EOF

#Создать корневой сертификат. Обязательно ввести сложный пароль и Common Name сервера, например my vpn server:
# created ${PKI_DIR}/certs_by_serial/
# created ${PKI_DIR}/issued/
# created ${PKI_DIR}/revoked/
# created ${PKI_DIR}/revoked/certs_by_serial/
# created ${PKI_DIR}/revoked/private_by_serial/
# created ${PKI_DIR}/revoked/reqs_by_serial/
# created ${PKI_DIR}/index.txt
# created ${PKI_DIR}/index.txt.attr
# created ${PKI_DIR}/openssl-easyrsa.cnf
# created ${PKI_DIR}/safessl-easyrsa.cnf
# created ${PKI_DIR}/serial
${EASYRSA_COMMAND} build-ca


# Создать ключи Диффи-Хелмана:
# created ${PKI_DIR}/dh.pem
${EASYRSA_COMMAND} gen-dh
mv "${PKI_DIR}/dh.pem" "${PKI_DIR}/dh2048.pem"


#Создать запрос на сертификат для сервера OVPN. Обращаю внимание, что сертификат будет незапаролен (параметр nopass), иначе при каждом старте OpenVPN будет запрашивать этот пароль:
# created ${PKI_DIR}/reqs/server.req
# created ${PKI_DIR}/private/server.key
${EASYRSA_COMMAND} gen-req server nopass


# Создать сам сертификат сервера OVPN:
# created ${PKI_DIR}/private/ca.key:
# created ${PKI_DIR}/issued/server.crt
# created ${PKI_DIR}/certs_by_serial/CDA23464ECE55CC319219973DDDE36EF.pem
# created ${PKI_DIR}/ca.crt

# updated ${PKI_DIR}/index.txt (0 bytes - 69 bytes)
# content of  ${PKI_DIR}/index.txt:
# V       241214123604Z           CDA23464ECE55CC319219973DDDE36EF        unknown /CN=doctor

# updated ${PKI_DIR}/index.txt.attr (0 bytes - 20 bytes)
# content of  ${PKI_DIR}/index.txt.attr:
# unique_subject = no


# updated ${PKI_DIR}/serial (content '01' - content 'CDA23464ECE55CC319219973DDDE36EF')
${EASYRSA_COMMAND} sign-req server server

# Скопировать полученные ключи в рабочий каталог openvpn:
sudo cp ${PKI_DIR}/ca.crt ${SERVER_DIR}
sudo cp ${PKI_DIR}/issued/server.crt ${SERVER_DIR}
sudo cp ${PKI_DIR}/private/server.key ${SERVER_DIR}
sudo cp ${PKI_DIR}/dh2048.pem ${SERVER_DIR}
sudo openvpn --genkey secret ${SERVER_DIR}/ta.key
if [[ "${DISTRO}" == '"Arch Linux"' ]] ; then
  sudo chown -R openvpn:network ${SERVER_DIR}
fi

if [[ "${DISTRO}" == '"Arch Linux"' ]] ; then
  sudo cp /usr/share/openvpn/examples/server.conf ${SERVER_DIR}
else
  sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf ${SERVER_DIR}
fi
sudo sed -i '/^tls-auth/{s/^/# /;s/$/\ntls-crypt ta.key/}' ${SERVER_DIR}/server.conf
sudo sed -i '/^tls-auth/{s/^/# /;s/$/\ntls-crypt ta.key/}' ${SERVER_DIR}/server.conf
sudo sed -i '/^cipher/{s/^/# /;s/$/\ncipher AES-256-GCM\nauth SHA256/}' ${SERVER_DIR}/server.conf
sudo sed -i -E '/^;(user|group)/{s/^;//}' ${SERVER_DIR}/server.conf
echo 'net.ipv4.ip_forward = 1' | sudo tee /usr/lib/sysctl.d/99-forwarding.conf > /dev/null
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null

DEVICE=$(sudo ip route show default | grep -oP '(?<=(dev\s))(.+?\b)')
if [ -f /etc/ufw/before.rules.bak ] ; then
  sudo cp /etc/ufw/before.rules.bak /etc/ufw/before.rules
fi
cat << EOF | (sudo head -n10 /etc/ufw/before.rules ; cat - ; sudo sed -n '10,$p' /etc/ufw/before.rules ) | sudo tee /etc/ufw/before.rules.new > /dev/null
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
sudo systemctl restart openvpn-server@server.service
sudo systemctl status --no-pager openvpn-server@server.service

if [[ "${DISTRO}" == '"Arch Linux"' ]] ; then
  sudo cp /usr/share/openvpn/examples/client.conf ${CLIENT_DIR}
else
  sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ${CLIENT_DIR}
fi
