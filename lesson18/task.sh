#!/bin/bash
SCRIPT_DIR="$(dirname $(realpath $0))"

# Директорія для роботи з файлами
export DIRECTORY="${PWD}"

# Віддалений хост. Можна використовувати:
# хост із ~/.ssh/config
# ip-адресу
# хост із /etc/hosts
# DNS-ім'я
export REMOTE_HOST='remote_host'

# Директорії на віддаленому хості

# Для копіювання файлів на віддалений хост
export REMOTE_DIRECTORY_TO='~/remote_to'
# Для копіювання файлів з віддаленого хосту
export REMOTE_DIRECTORY_FROM='~/remote_from'

# Мінімум файлів для копіювання на віддалений хост
# Якщо файлів в робочому каталозі не вистачатиме, створяться додаткові файли
export MIN_FILES_TO=3

# Кількість файлів для створення на віддаленому хості
export COUNT_FILES_FROM=2

# Завантажимо необхідний набір функцій із файлу lib.sh
source "${SCRIPT_DIR}/lib.sh"

# Якщо скрипт знаходиться в поточному каталозі, створимо поруч новий каталог і зробимо його основним
# Інакше працюватимемо із пототочним каталогом
if [ $SCRIPT_DIR == $DIRECTORY ] ; then
	DIRECTORY="$DIRECTORY/workdir_$(date +%s_%3N)"
	mkdir -v "$DIRECTORY"
fi

# Дістаємо список файлів із поточного каталогу
get_local_files

# Копіюємо файли з поточного каталогу на віддалений хост
copy_to_remotedir

# Відображаємо лістинг файлів у віддаленому каталозі
list_remote_files

# Видаляємо локально скопійовані на віддалений хост файли
rm_local_files

# Створюємо на віддаленому хості потрібну кількість файлів
makefiles_remote ${COUNT_FILES_FROM}

# Копіюємо новостворені файли на локальний хост
copy_from_remotedir
