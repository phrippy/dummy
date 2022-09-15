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
