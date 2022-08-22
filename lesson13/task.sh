#!/bin/bash

# Якщо в домашньому каталозі не існує об'єкту з ім'ям task
# то створимо каталог з таким ім'ям
DIRECTORY="$HOME/task"
if [[ ! -e "${DIRECTORY}" ]] ; then
  mkdir -pv "${DIRECTORY}"
fi

# Якщо ж такий об'єкт вже існує і це не каталог
# то аварійно завершимо роботу
if [[ ! -d "${DIRECTORY}" ]] ; then
 echo "${DIRECTORY} is not directory!"
 echo "Aborting..."
 exit 1
fi

# Два варіанти, щоб дістати список груп
# Можна було б скористатися командою groups,
# але вона повертає список тільки тих груп, в яких користувач учасник
groups1=$(cat /etc/group | grep -oP '^.*?(?=(:))')
groups2=$(cat /etc/group | tr ':' ' ' | awk '{print $1}')

# Створюємо в цільовому каталозі каталоги з іменами груп
for i in $groups1
  do
    mkdir -pv "${DIRECTORY}/$i"
done

# Встановлюємо права власника відповідно до завдання
# Ця операція потребує прав суперкористувача, тому запускаємо через sudo
for i in "${DIRECTORY}"/*
  do
    sudo chown -v root:$(basename "$i") "${i}"
    sudo chmod -v 607 "${i}"
done

# Додаємо до цільового каталогу біти sguid і stiky
sudo chmod -v g+s "${DIRECTORY}"
sudo chmod -v o+t "${DIRECTORY}"

# Створюємо тестовий файл і жорстке та м'яке посилання на нього
touch "${DIRECTORY}/testfile"
ln --physical --verbose "${DIRECTORY}/testfile" "${DIRECTORY}/hardlink_file"
ln --symbolic --relative --verbose "${DIRECTORY}/testfile" "${DIRECTORY}/softlink_file"

# Створюємо десять файлів з випадковим розміром і даними
for i in {0..9}
  do
    dd if=/dev/urandom of="$DIRECTORY/file${i}.dat" bs=1 count=$RANDOM
done

# Переходимо в каталог зі згенерованими файлами
cd "${DIRECTORY}"/..
# Генеруємо tar.gz архів із цими файлами
tar cvzf "${DIRECTORY}/archive.tar.gz" $(basename $DIRECTORY)/*.dat
# За потреби додати специфічні опції стиснення
# чи для використання компресора, який не підтримується tar
# можна використовувати альтернативний синтаксис:
# tar cf - $(basename $DIRECTORY)/*.dat | gzip -9 > "${DIRECTORY}/archive.tar.gz"
