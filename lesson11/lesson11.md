# Памʼятати останні 4 паролі
Для запам'ятовування старих паролів використовуються два pam-модулі:
1. `pam_unix.so`
2. `pam_pwhistory.so`

В обох випадках старі паролі зберігатимуться в файлі `/etc/security/opasswd/<імʼя користувача>`. Очевидно, було б нерозумно використовувати ці модулі одночасно

## Модуль pam_unix.so
Редагуємо файл `/etc/pam.d/common-password`. Знаходимо рядок, де відбувається виклик модулю `pam_unix.so` з типом `password` (в нашому випадку це рядок 25). Дописуємо в ньому через пробіл `remember=4`

Повинно вийти так:
```diff
- password        [success=1 default=ignore]      pam_unix.so obscure yescrypt
+ password        [success=1 default=ignore]      pam_unix.so obscure yescrypt remember=4
```

![Налаштування pam_unix.so в файлі /etc/pam.d/common-password](pam_unix.png)

Налаштування запрацюють після збереження файлу. Але є одна проблема: цей модуль не працює з суперкористувачем. Якщо потрібно обмежити і суперкористувача, потрібно використовувати модуль `pam_pwhistory.so`

## Модуль pam_pwhistory.so
Ключова відмінність від попереднього модуля - підримка обмежень в тому числі і для суперкористувача.

Редагуємо той же самий файл `/etc/pam.d/common-password`, але в цьому варіанті не редагуємо відповідний рядок, а додаємо новий рядок над ним. Повинно вийти так:
```diff
+ password        required pam_pwhistory.so remember=4
  password        [success=1 default=ignore]      pam_unix.so obscure yescryp
```

Щоб дати користувачу три спроби для введення паролю замість однієї, можна додати параметр `retry=3`. А щоб обмежитити і суперкористувача (заради чого ми, власне, і зібралися використовувати модуль `pam_pwhistory.so`, треба додати параметр `enforce_for_root`. Дописуємо ці параметри через пробіл в кінець рядка, в якому викликається модуль `pam_pwhistory.so` з типом `password`

Кінцевий рабочий варіант виглядатиме так:

```diff
+ password        required pam_pwhistory.so remember=4 retry=3 enforce_for_root
  password        [success=1 default=ignore]      pam_unix.so obscure yescryp
```

![Налаштування pam_pwhistory.so в файлі /etc/pam.d/common-password](pam_pwhistory.png)

Для тесту створимо нового користувача, одразу задавши йому оболонку за замовчуванням і створивши домашній каталог. Також встановимо йому пароль

```bash
sudo useradd -m -s /bin/bash test
sudo passwd test
```

При спробі змінити пароль на один із чотирьох збережених отримаємо очікувану помилку

![Спроба змінити пароль на той, що вже був використаний](password_used.png)

Оскільки останні паролі користувача `test` зберігаються в файлі `/etc/security/opasswd/test`, то при видаленні цього файлу користувач знову зможе встановити один з чотирьох останніх паролів. На практиці так робити не варто 
___

# Вимоги до паролів
```pam_cracklib```
Або
```pam_pwquality```
Уточнити

*Порівняти налаштування цього модулю за замовчуванням в Debian і ArchLinux*

___

# Блокуємо користувача після 5 введень неправильного паролю
```pam_faillock```

https://blog.sedicomm.com/2018/10/24/kak-zablokirovat-uchetnuyu-zapis-polzovatelya-posle-nekotorogo-kolichestva-neudachnyh-popytok-vhoda-v-sistemu/

* Змінюємо файл `/etc/pam.d/common-auth`

![Налаштування файлу /etc/pam.d/common-auth](common_auth.png)

```diff
+ auth     requisite       pam_faillock.so preauth
  auth    [success=1 default=ignore]      pam_unix.so nullok
+ auth     sufficient     pam_faillock.so authsucc
  # here's the fallback if no module succeeds
  auth    requisite                       pam_deny.so
+ account  required       pam_faillock.so
```

* Інформація про невдалі логіни буде зберігатися в каталозі `/var/run/faillock/`

___

# Час життя паролю - 90 днів

```bash
sudo chage -M 90 username
sudo chage -l username
```
