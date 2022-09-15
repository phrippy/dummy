#!/bin/bash
PKI_DIR=/etc/openvpn/pki
EASYRSA=/usr/share/easy-rsa/easyrsa
COMMAND="${EASYRSA} --pki-dir=${PKI_DIR}"
SERVER_DIR=/etc/openvpn/server
CLIENT_DIR=/etc/openvpn/client

# Функція створює PKI (Public Key Infrastructure) - інфраструктуру відкритих ключів
# Потім створює кореневий сертифікат і копіює його в директорії сервера і клієнта
key-init(){
  $COMMAND init-pki
  $COMMAND build-ca
	mkdir /etc/openvpn/ccd	
  cp -v $PKI_DIR/ca.crt $SERVER_DIR
  cp -v $PKI_DIR/ca.crt $CLIENT_DIR
  openvpn --genkey secret ${PKI_DIR}/ta.key
  cp -v $PKI_DIR/ta.key $SERVER_DIR
  cp -v $PKI_DIR/ta.key $CLIENT_DIR
  $COMMAND gen-crl
  cp -v ${PKI_DIR}/crl.pem $SERVER_DIR
}

# Створення і копіювання в потрібні директорії ключа і сертифіката для серверу
key-server(){
  name=${1-server1}
  $COMMAND gen-req ${name} nopass
  cp -v ${PKI_DIR}/private/${name}.key $SERVER_DIR
  $COMMAND sign-req server ${name} 
  cp -v ${PKI_DIR}/issued/${name}.crt $SERVER_DIR
}

# Створення і копіювання в потрібні директорії ключа і сертифіката для клієнту
# Потрібно генерувати окремий ключ для кожного клієнту,
# бо openvpn генерує однакові ip-адреси для однакових ключів
# Щоб це обійти, потрібно додати рядок duplicate-cn в файл конфігурації серверу
key-client(){
  name=${1-client1}
  $COMMAND gen-req ${name} nopass
  cp -v ${PKI_DIR}/private/${name}.key $CLIENT_DIR
  $COMMAND sign-req client ${name} 
  cp -v ${PKI_DIR}/issued/${name}.crt $CLIENT_DIR
}
