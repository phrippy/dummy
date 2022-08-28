# Перевіряємо скільки і які шелли встановлені в системі:

```cat /etc/shells```

![Список шеллів в файлі /etc/shells](etc_shells.png)

Якась дичина. Виявляється, деякі файли і каталоги в цьому списку є символічними посиланнями. Що ж, напишемо скрипт, який коректно виведе встановлені в системі шелли:

```bash
#!/bin/bash
for i in $(
  cat /etc/shells | # Зчитуємо файл зі списком шеллів
  grep -P '^[^#]'   # Прибираємо коментарі
  )
do
  # Якщо файл чи каталог, в якому знаходиться цей файл
  # не є символічним посиланням
  if [ ! -L $i ] && [ ! -L $(dirname $i) ]; then
    echo $(basename $i)  # То виводимо на stdout назву шелла
  fi
done |
cat -n # Додаємо номери рядків
```

* Тепер вивід виглядає набагато краще:

![Список шеллів](etc_shells_script.png)

# Поточний шелл можна дізнатися командою `ps`:

![Вивід команди ps](ps.png)

# Вміст змінної $SHELL дізнаємося командою `echo $SHELL`:

![Значення змінної $SHELL](shell_var.png)

# Також поточний шелл можна дізнатися командою readlink:

```readlink /proc/$$/exe```

* `$$` - це змінна, що зберігає PID поточного процесу
* Файл /proc/<PID процесу>/exe є символічним посиланням на файл, з якого процес був запущений
* Команда `readlink` зчитує символічне посилання і повертає цільовий шлях до файлу
* Як бачимо, хоча шелл у нас `/bin/zsh`, команда вивела `/usr/bin/zsh`, оскільки в моїй системі каталог `/bin` є символічним посиланням на `/usr/bin`

![Шлях до поточного шеллу по команді readlink](readlink_proc.png)

# Перевірка поточної версії шелла
Можна скористатись командою `$SHELL --version`, але вона не є універсальною:

![Версія шеллу](shell_version.png)

## Альтернативний варіант

Шелл dash настільки вбогий, що не розуміє опцію `--version`. Тому за потреби доведеться скористатися послугами пакетного менеджера:

![Версія dash](dash.png)

# Змінюємо шелл за замовчуванням на bash

```chsh -s /bin/bash```

![Зміна шеллу за замовчуванням](chsh.png)

# Порівнюємо змінні середовища із tty і ssh сесій
* Змінні середовища із tty можна дістати, залогінившись в tty. Відсортуємо їх і запишемо в файл:

![Зміні середовища в tty](tty_env.png)

1. Змінні середовища із ssh можна дістати навіть в графічному терміналі

   Для цього потрібно виконати команду `ssh localhost env`. Тому в файл їх писати не будемо, а одразу передамо на вивід команді diff:

2. u означає виводити дані в форматі git
3. 0 - кількіть унікальних рядків, які буде виведено. Нас цікавлять тільки відмінності, тому ставимо нуль
4. Оскільки команда `diff` не працює з stdin, доведеться скористатися функцією нелінійного конвеєра:

   конструкція `<(command)` означає виконати `command`, записати її вивід в тимчасовий файл в каталозі `/dev/fd` і передати цей файл команді `diff` як аргумент

5. grep відбере тільки рядки, що починаються з + або -
6. Команда cut обріже довгий рядок змінної $LS_COLORS
7. colordiff розфарбує вивід

```diff -u0 ~/tty_env <(ssh localhost env|sort) | grep -P '^[+-]' | cut -c -${COLUMNS} | colordiff```

![Різниця змінних середовища в tty і ssh](env_diff.png)

* Отримаємо різницю двох середовищ.
* "Видалені" рядки - це змінні середовища в tty, а "додані" - це змінні середовища в ssh

```diff
--- /home/phrippy/tty_env       2022-08-28 16:42:29.145285704 +0300
+++ /dev/fd/63  2022-08-28 17:39:23.348282012 +0300
-HUSHLOGIN=FALSE
-INVOCATION_ID=e6d0c22896274248ac0df54e4820faf3
-JOURNAL_STREAM=8:37213
-LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=
-MAIL=/var/mail/phrippy
-PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
+PATH=/usr/local/bin:/usr/bin:/bin:/usr/games
-TERM=linux
+SSH_CLIENT=::1 38102 22
+SSH_CONNECTION=::1 38102 ::1 22
-XDG_SEAT=seat0
-XDG_SESSION_ID=39
+XDG_SESSION_ID=87
-XDG_VTNR=2
```
# Дістаємо список змінних середовища
Для цього просто запустимо команду `env`. Отримаємо довгий список:

```ini
SHELL=/bin/bash
WINDOWID=0
QT_ACCESSIBILITY=1
COLORTERM=truecolor
XDG_CONFIG_DIRS=/etc:/etc/xdg:/usr/share
XDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session1
XDG_MENU_PREFIX=lxqt-
LANGUAGE=
SSH_AUTH_SOCK=/tmp/ssh-baxvDnkvzPi7/agent.1701
XDG_DATA_HOME=/home/phrippy/.local/share
XDG_CONFIG_HOME=/home/phrippy/.config
DESKTOP_SESSION=lxqt
LXQT_SESSION_CONFIG=session
SSH_AGENT_PID=1744
GTK_MODULES=gail:atk-bridge
XDG_SEAT=seat0
PWD=/home/phrippy
XDG_SESSION_DESKTOP=
LOGNAME=phrippy
QT_QPA_PLATFORMTHEME=lxqt
XDG_SESSION_TYPE=x11
GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1
XAUTHORITY=/home/phrippy/.Xauthority
HOME=/home/phrippy
LANG=uk_UA.UTF-8
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
XDG_CURRENT_DESKTOP=LXQt
XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
GTK_CSD=0
XDG_CACHE_HOME=/home/phrippy/.cache
XDG_SESSION_CLASS=user
TERM=xterm-256color
GTK_OVERLAY_SCROLLING=0
USER=phrippy
COLORFGBG=15;0
DISPLAY=:0
SHLVL=3
XDG_VTNR=7
XDG_SESSION_ID=3
XDG_RUNTIME_DIR=/run/user/1000
QT_PLATFORM_PLUGIN=lxqt
XDG_DATA_DIRS=/home/phrippy/.local/share:/usr/local/share:/usr/share
BROWSER=firefox
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
MAIL=/var/mail/phrippy
OLDPWD=/home/phrippy
_=/usr/bin/env
```
