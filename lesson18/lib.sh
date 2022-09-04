declare -xa FILES_TO_COPY=()
declare -xa FILES_FROM_COPY=()

check_remote_dir(){
	# Функція для перевірки існування каталогів на віддаленому хості
	# Якщо каталогу не існує - він буде створений
	# Якщо з потрібним іменем буде існувати не каталог, а файл - 
	# скрипт аварійно завершить роботу
cat <<EOF | ssh ${REMOTE_HOST} bash
	if [ ! -e $1 ] ; then
		mkdir -pv $1
	else
		if [ ! -d $1 ] ; then
			echo "Віддалений об'єкт $1 не є каталогом. Завершення роботи" >&2
			exit 1
		fi
	fi
EOF
}

get_local_files(){
	# Дістаємо список файлів із поточного каталогу і записуємо їх в масив $FILES_TO_COPY[]
	FILES_TO_COPY=()
	while IFS= read -r -d $'\0' ; do
		FILES_TO_COPY+=("${REPLY}")
	done < <(find "${DIRECTORY}"/* -maxdepth 0 -type f -print0 2> /dev/null)
}

list_remote_files(){
	# Просто список скопійованих файлів на віддаленому хості
	echo -n "Список файлів у віддаленому каталозі "
	ssh ${REMOTE_HOST} "echo ${REMOTE_DIRECTORY_TO} ; ls -lh ${REMOTE_DIRECTORY_TO}"
}

rm_local_files(){
	# Видаляємо скопійовані раніше на віддалений хост файли за допомогою xargs
	printf "%s\n" "${FILES_TO_COPY[@]}" | xargs rm -v
}

get_remote_files(){
	# Дістаємо список всіх файлів з віддаленого каталогу із створеними файлами
	# Функція не використовується, список генерується під час створення файлів
	# Тому файли, що вже існували у віддаленому каталозі, скопійовані на локальний хост не будуть
	FILES_FROM_COPY=()
	while IFS= read -r -d $'\0' ; do
		FILES_FROM_COPY+=("${REPLY}")
	done < <(ssh "${REMOTE_HOST}" find "${REMOTE_DIRECTORY_FROM}"/* -maxdepth 0 -type f -print0 2> /dev/null)
}

copy_from_remotedir(){
	# Копіюємо файли з віддаленого хосту
	printf "${REMOTE_HOST}:%s\n" "${FILES_FROM_COPY[@]}" | xargs -I {} scp "{}" "${DIRECTORY}"
}

copy_to_remotedir() {
	# Копіюємо файли на віддалений хост у відповідний каталог
	FILES_COUNT="${#FILES_TO_COPY[@]}"
	if [ ${FILES_COUNT} -le $MIN_FILES_TO ] ; then
		# Перевірка на потрібну кількість файлів
		echo "Замало файлів. Знайдено ${FILES_COUNT}, а потрібно як мінімум ${MIN_FILES_TO}" >&2
		NEEDED_FILES=$((MIN_FILES_TO - FILES_COUNT))
		echo "Не вистачає файлів: ${NEEDED_FILES}"
		# Якщо файлів не вистачає, створимо потрібну їх кількість
		makefiles_local ${NEEDED_FILES}
		# Згенеруємо список файлів для копіювання на віддалений хост
		get_local_files
	fi
	# Якщо віддаленого каталогу для копіювання не існує
	# і його не вдалося створити
	# То аварійно завершуємо роботу скрипта
	check_remote_dir $REMOTE_DIRECTORY_TO || exit $?
	# Безпосередньо копіюємо всі файли на віддалений хост
	for i in "${FILES_TO_COPY[@]}" ; do
		scp "$i" ${REMOTE_HOST}:"${REMOTE_DIRECTORY_TO}"
	done
}

makefiles_local(){
	# Створюємо файли на локальному хості
	DEFAULT_FILES=3
	COUNTER="${1-${DEFAULT_FILES}}"
	for i in $(seq 1 ${COUNTER})
	 do
		 FILENAME="$DIRECTORY/local_file_$(date +%s_%3N).dat"
		 echo "Створюю локальний файл '${FILENAME}'"
		 dd if=/dev/urandom of="$FILENAME" bs=1 count=$RANDOM 2> /dev/null
	done
}

makefiles_remote(){
	# Створюємо файли на віддаленому хості

	# Якщо потрібної директорії на віддаленому хості не існує
	# і її не вдалося створити
	# То аварійно завершуємо роботу скрипта
	check_remote_dir $REMOTE_DIRECTORY_FROM || exit $?

	DEFAULT_FILES=2
	COUNTER="${1-${DEFAULT_FILES}}"
	FILES_FROM_COPY=()
	for i in $(seq 1 ${COUNTER}) ; do
		FILENAME="$REMOTE_DIRECTORY_FROM/remote_file_$(date +%s_%3N).dat"
		echo "Створюю віддалений файл '${FILENAME}'"
		FILES_FROM_COPY+=("${FILENAME}")
		ssh "${REMOTE_HOST}" dd if=/dev/urandom of="$FILENAME" bs=1 count=$RANDOM 2> /dev/null
	done
}
