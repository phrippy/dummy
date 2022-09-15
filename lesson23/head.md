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


Створюємо папку і робимо в ній символьні посилання на файли з пакету easy-rsa:

*В принципі, можна було б їх скопіювати, але рішення із символічними посиланнями відображатиме всі майбутні оновлення пакету easy-rsa в нашій папці*

```bash
mkdir ~/easy-rsa
# В принципі, можна було б їх скопіювати, але рішення із символічними посиланнями відображатиме всі майбутні оновлення пакету easy-rsa в нашій папці
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
# Налаштовуємо потрібні права
sudo chown $USER ~/easy-rsa
chmod 700 ~/easy-rsa
```

Налаштовуємо алгоритм шифрування:

```bash
cat <<EOF | sudo tee -a ~/easy-rsa/vars
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"
EOF

Ініціалізуємо середовище для приватних ключів:

```bash
~/easyrsa init-pki
```

# Спроба 2:
```
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip
cd ~/easy-rsa-master/easyrsa3
cp ~/easy-rsa-master/easyrsa3/vars.example ~/easy-rsa-master/easyrsa3/vars
cat <<EOF >> ./vars
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"
EOF
```

```bash
Инициализировать PKI (Public Key Infrastructure — Инфраструктура открытых ключей):
./easyrsa init-pki
Создать корневой сертификат. Обязательно ввести сложный пароль и Common Name сервера, например my vpn server:
./easyrsa build-ca
Создать ключи Диффи-Хелмана:
./easyrsa gen-dh
Создать запрос на сертификат для сервера OVPN. Обращаю внимание, что сертификат будет незапаролен (параметр nopass), иначе при каждом старте OpenVPN будет запрашивать этот пароль:
./easyrsa gen-req vpn-server nopass
Создать сам сертификат сервера OVPN:
./easyrsa sign-req server vpn-server
```
