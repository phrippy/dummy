# Встановлюємо необхідні пакети:

```bash
sudo apt update
sudo apt install openvpn easy-rsa
```

# Генеруємо необхідний набір ключів

Для цього напишемо простенький скрипт:

```bash
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
```

Тепер імпортуємо всі змінні і функції із новоствореного скрипта:

```bash
source ./keygen.sh
```

Після цього ініціалізуємо середовище:

```bash
key-init
```

Створимо ключі і сертифікати для сервера:

```bash
key-server server1
```

Створимо ключі і сертифікати для клієнта:

```bash
key-client client1
```
Тепер прийшла пора створити файл конфігурації. Для цього теж можна написати скрипт:


```bash
port 1194
proto udp
dev tun
user nobody
group nogroup
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "redirect-gateway def1 bypass-dhcp"
dh none
ecdh-curve prime256v1
tls-crypt /etc/openvpn/server/ta.key
crl-verify /etc/openvpn/server/crl.pem
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
auth SHA256
cipher AES-128-GCM
ncp-ciphers AES-128-GCM
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
client-config-dir /etc/openvpn/ccd
status /var/log/openvpn/status.log
verb 3
duplicate-cn
```

