* Настроить VPN соединение между (на выбор) две виртуалки в облаке/виртуалка в облаке - виртуалка на локальной рабочей станции.

* Можно использовать OpenVPN либо любой другой.

(https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04-ru)

(https://adw0rd.com/2013/01/10/openvpn/)

# Налаштовуємо сервер

1. Встановлюємо необхідні пакети:

```bash
sudo apt update
sudo apt install openvpn easy-rsa
```

2. Генеруємо необхідний набір ключів

Для цього напишемо простенький скрипт:

```bash
#!/bin/bash
PKI_DIR=/etc/openvpn/pki
PKI_DIR="$(realpath $PWD)"/pki
EASYRSA=/usr/share/easy-rsa/easyrsa
COMMAND="${EASYRSA} --pki-dir=${PKI_DIR}"
SERVER_DIR=/etc/openvpn/server
CLIENT_DIR=/etc/openvpn/client

key-init(){
  $COMMAND init-pki
  $COMMAND build-ca
  cp -v $PKI_DIR/ca.crt $SERVER_DIR
  cp -v $PKI_DIR/ca.crt $CLIENT_DIR
  openvpn --genkey secret ${PKI_DIR}/ta.key
  cp -v $PKI_DIR/ta.key $SERVER_DIR
  cp -v $PKI_DIR/ta.key $CLIENT_DIR
  $COMMAND gen-crl
  cp -v ${PKI_DIR}/crl.pem $SERVER_DIR
}

key-server(){
  name=${1-server1}
  $COMMAND gen-req ${name} nopass
  cp -v ${PKI_DIR}/private/${name}.key $SERVER_DIR
  $COMMAND sign-req server ${name} 
  cp -v ${PKI_DIR}/issued/${name}.crt $SERVER_DIR
}

key-client(){
  name=${1-client1}
  $COMMAND gen-req ${name} nopass
  cp -v ${PKI_DIR}/private/${name}.key $CLIENT_DIR
  $COMMAND sign-req client ${name} 
  cp -v ${PKI_DIR}/issued/${name}.crt $CLIENT_DIR
}
```

