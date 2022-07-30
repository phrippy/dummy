# Запам'ятовування старих паролів
Для запам'ятовування старих паролів використовуються два pam-модулі:
1. pam_unix.so
2. pam_pwhistory.so

В обох випадках старі паролі зберігатимуться в файлі `/etc/security/opasswd`. Новий пароль не може бути одним із тих, що зберігається в файлі `/etc/security/opasswd`. Очевидно, було б нерозумно використовувати ці модулі одночасно

## Модуль pam_unix.so
Редагуємо файл `/etc/pam.d/common-password`. Знаходимо перший незакоментований рядок, в якому згадується `pam_unix.so` і дописуємо в ньому через пробіл `remember=4`

В мене вийшло так:
```diff

- password        [success=1 default=ignore]      pam_unix.so obscure yescrypt
+ password        [success=1 default=ignore]      pam_unix.so obscure yescrypt remember=4```

## Модуль pam_pwhistory.so
Ключова відмінність від попереднього модуля - підримка обмежень в тому числі і для суперкористувача.

Редагуємо той же самий файл `/etc/pam.d/common-password`, але в цьому варіанті не редагуємо відповідний рядок, а додаємо новий рядок над ним. Повинно вийти так:
```diff
+ password        required        pam_pwhistory.so remember=4 retry=3 enforce_for_root
  password        [success=1 default=ignore]      pam_unix.so obscure yescryp
```
Окрім безпосередньо параметра `remember=4`, який зберігатиме чотири останні паролі, я додав `retry=3`, щоб при зміні паролю було три спроби, інакше якщо ввести вже збережений старий пароль при зміні паролю командою `passwd`, то програма просто завершиться з помилкою. А так повідомить, що було введено старий пароль і дасть ще три спроби.

І звісно параметр `enforce_for_root`, щоб обмеження спрацьовували і з суперкористувачем

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
