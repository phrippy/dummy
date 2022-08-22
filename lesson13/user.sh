#!/bin/bash

create () {
  # Одразу перевіряємо, чи існує користувач з таким іменем
  # Якщо існує - завершуємо роботу
  if id -u "${1}" >/dev/null 2>&1; then
   echo "Username ${1} is already exist" >&2
   echo "Please choose another username" >&2
   exit 201
  fi

  echo "Creating user ${1}..."
  useradd --create-home --shell /bin/bash ${USERNAME}

  echo "Adding ${1} to sudoers..."
  echo "${1} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/$1"

  if [ $(type -t echo) != 'builtin' ] ; then
    echo "'echo' is not builtin command. It is $(which echo)" >&2
    echo 'Cannot set password. Exiting...' >&2
    exit 202
  fi

  echo "Setting password for ${USERNAME}..."
  echo -n "${1}:${2}" | chpasswd
  exit 0
}

delete () {
  echo "Deleting ${1}..."
  userdel -r ${1} >/dev/null 2>&1
  rm -fv "/etc/sudoers.d/${1}"
}

# Підтримка короткої довідки
# Потрібно викликати скрипт з параметрами -h або --help
help () {
  cat << EOF
Usage:

$0 username [password]
$0 [ -c | --create ] username [password]

$0 [ -d | --delete ] username

$0 [ -h | --help ]

EOF
}

case "${1}" in
  -h|--help)
    help
    exit 0
    ;;
  -d|--delete)
    # Буде запущено видалення користувача 
    MODE=delete
    shift
    ;;
  -c|--create)
    # Опція за замовчуванням, зробив для краси
    shift
    ;;
  *)
    # Буде запущено створення користувача 
esac

# Оскільки створювати нового користувача можна тільки від імені суперкористувача
# то ми просто завершимо роботу скрипта
if [[ $EUID -ne 0 ]] ; then
  echo 'Please run this script as root'
  exit 200
fi


# Ім'я і пароль нового користувача задаються як параметри скрипта
# Якщо параметри не задано, буде використано значення за замовучанням
DEFAULT_USERNAME=john
DEFAULT_PASSWORD=qwerty
USERNAME=${1-${DEFAULT_USERNAME}}
PASSWORD=${2-${DEFAULT_PASSWORD}}

${MODE-create} "${USERNAME}" "${PASSWORD}"
echo Done!
