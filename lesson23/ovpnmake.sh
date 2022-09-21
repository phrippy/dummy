#!/bin/bash
name=${1-client1}
(
cat client.conf
echo '<ca>'
cat ca.crt
echo '</ca>'
echo '<cert>'
cat ${name}.crt
echo '</cert>'
echo '<key>'
cat ${name}.key
echo '</key>'
echo '<tls-crypt>'
cat ta.key
echo '</tls-crypt>'
)> ${name}.ovpn
