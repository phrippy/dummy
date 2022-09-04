export DIRECTORY=${PWD}
export REMOTE_HOST='remote_host'
export REMOTE_DIRECTORY_TO='~/remote_to'
export REMOTE_DIRECTORY_FROM='~/remote_from'
export MIN_FILES_TO=3
export MIN_FILES_FROM=2
declare -xa FILES_TO_COPY=()
declare -xa FILES_FROM_COPY=()

check_remote_dir(){
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
	FILES_TO_COPY=()
	while IFS= read -r -d $'\0' ; do
		FILES_TO_COPY+=("${REPLY}")
	done < <(find "${DIRECTORY}"/* -maxdepth 0 -type f -print0 2> /dev/null)
}

list_remote_files(){
	echo -n "Список файлів у віддаленому каталозі "
	ssh ${REMOTE_HOST} "echo ${REMOTE_DIRECTORY_TO} ; ls -lh ${REMOTE_DIRECTORY_TO}"
}

rm_local_files(){
	# Видаляємо за допомогою xargs
	printf "%s\n" "${FILES_TO_COPY[@]}" | xargs rm -v
}

makefiles_remote(){
	echo $FUNCNAME

}

get_remote_files(){
	echo $FUNCNAME

}

copy_from_remotedir(){
	echo $FUNCNAME

}

copy_to_remotedir() {
	FILES_COUNT="${#FILES_TO_COPY[@]}"
	if [ ${FILES_COUNT} -le $MIN_FILES_TO ] ; then
		echo "Замало файлів. Знайдено ${FILES_COUNT}, а потрібно як мінімум ${MIN_FILES_TO}" >&2
		NEEDED_FILES=$((MIN_FILES_TO - FILES_COUNT))
		echo "Не вистачає файлів: ${NEEDED_FILES}"
		makefiles_local ${NEEDED_FILES}
		get_local_files
	fi
	check_remote_dir $REMOTE_DIRECTORY_TO || exit $?
	for i in "${FILES_TO_COPY[@]}" ; do
		scp "$i" ${REMOTE_HOST}:"${REMOTE_DIRECTORY_TO}"
	done
}

makefiles_local(){
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
	check_remote_dir $REMOTE_DIRECTORY_FROM || exit $?
	DEFAULT_FILES=2
	COUNTER="${1-${DEFAULT_FILES}}"
	for i in $(seq 1 ${COUNTER})
	 do
		 FILENAME="$REMOTE_DIRECTORY_FROM/remote_file_$(date +%s_%3N).dat"
		 echo "Створюю віддалений файл '${FILENAME}'"
		 ssh "${REMOTE_HOST}" dd if=/dev/urandom of="$FILENAME" bs=1 count=$RANDOM 2> /dev/null
	done
}
