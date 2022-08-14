# Генерація ключа
```bash
ssh-keygen -t rsa -f ~/.ssh/sshfs_key
```
1. сгенерировать пару ключей RSA для пользователя

# Копіювання ключа на інший хост
Для початку сконфігуруємо наш хост, додавши відповідні рядки в `~/.ssh/config`:

```bash
# Коротка назва хосту, яку будемо використовувати при підключенні
host from
	# Адреса хосту для доступу
	HostName	192.168.8.178
	# Ім'я користувача. Якщо не ввести, буде використано ім'я поточного користувача
	User		phrippy
	# Шлях до файлу з ключем, який мо попередньо згенерували
	# Звіно, можна генерувати ключ за стандартним ім'ям і розміщенням, а потім опускати цей рядок
	# Але це погана практика. В ідеалі, один сервер - один ключ
	IdentityFile	~/.ssh/sshfs_key
```
Оскільки все налаштовано, тепер достатньо дати команду `ssh-copy-id from`. Нас повинні запитати пароль

Того ж ефекту можна добитися, якщо передати ключ вручну: `cat ~/.ssh/sshfs_key.pub | ssh 'tee -a ~/.ssh/authorized_keys'`

Якщо парольний доступ для root заборонений, можна передати свій ключ через sudo: `cat ~/.ssh/sshfs_key.pub | ssh from 'sudo tee -a ~root/.ssh/authorized_keys'`

2. скопировать ключи на другой линукс хост (виртуальную машину)

# Забороняємо доступ по паролю
Редагуємо файл `/etc/ssh/sshd_config`:
```diff
  # To disable tunneled clear text passwords, change to no here!
- #PasswordAuthentication yes
+ #PasswordAuthentication no
  #PermitEmptyPasswords no
```
3. сконфигурировать беспарольный доступ на удаленный хост

# Монтуємо каталог через sshfs
```
sshfs -o allow_other from:/home/phrippy ./remote
fusermount -u ./remote
root@from:/home /mnt fuse.sshfs defaults,_netdev,IdentityFile=/phrippy/.ssh/shfs_key,allow_other 0 0
```
4. смонтировать в специально созданную директорию в домашнем каталоге директорию с другого линукс хоста по ссш.
