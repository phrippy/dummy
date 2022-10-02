Список всіх unix-сокетів можна дістати командою `netstat -ax`:

![Список unix-сокетів](sockets.png)

Список всіх tcp-сокетів - командою `netstat -atn`. Ключ `-n` потрібен для показу ip-адрес замість імен:

![Список tcp-сокетів](tcp.png)

Таблиця маршрутизації доступна по команді `netstat -r`:

![Таблиця маршрутизації](route.png)

Оскільки наступні маніпуляції ігноруються гіпервізором, будемо використовувати реальну машину

# Налаштування мережі за замовчуванням:

* ethtool

![Вивід команди ethtool, налаштування за замовчуванням](check1_ethtool.png)

* mii-tool

![Вивід команди mii-tool, налаштування за замовчуванням](check1_mii.png)
 
* Тест швидкості за допомогою `iperf`

![Тест швидкості через iperf, налаштування за замовчуванням](check1_iperf.png)

# Налаштування мережі після встановлення швидкості 100MBit, Full Duplex:

* ethtool

![Вивід команди ethtool, 100MBit Full Duplex](check2_ethtool_100full.png)

* mii-tool

![Вивід команди mii-tool, 100MBit Full Duplex](check2_mii_100full.png)
 
* Тест швидкості за допомогою `iperf`

![Тест швидкості через ipref, 100MBit Full Duplex](check2_iperf_100full.png)

# Налаштування мережі після встановлення швидкості 100MBit, Half Duplex:

* ethtool

![Вивід команди ethtool, 100MBit Half Duplex](check2_ethtool_100half.png)

* mii-tool

![Вивід команди mii-tool, 100MBit Half Duplex](check2_mii_100half.png)
 
* Тест швидкості за допомогою `iperf`

![Тест швидкості через iperf, 100MBit Half Duplex](check2_iperf_100half.png)

Схоже, в режимі half duplex 100MBit мережа почувається не дуже добре в режимі download. Це ж підтверджує і `speedtest-cli`:

![Тест швидкості через speedtest-cli, 100MBit Half Duplex](cli.png)

Загалом, висновок такий: краще за все використовувати режим Full Duplex і максимальну швидкість мережевого адаптеру, якщо тільки ситуація не потребує особливого втручання
