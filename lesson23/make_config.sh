#!/bin/bash

# First argument: Client identifier

KEY_DIR=/etc/openvpn/server
OUTPUT_DIR=/etc/openvpn/client/files
mkdir -p "${OUTPUT_DIR}"
BASE_CONFIG=/etc/openvpn/client/client.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    | sudo tee ${OUTPUT_DIR}/${1}.ovpn > /dev/null
sudo cp ${OUTPUT_DIR}/server.ovpn .
sudo chown 1000:1000 server.ovpn
