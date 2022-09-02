#!/bin/bash
export DIRECTORY=${PWD}
export REMOTE_DIRECTORY='~/remote'
export MIN_FILES=3
export FILES_TO_COPY=

copy_to_remotedir() {
	ARGS_COUNT="$#"
	if [ $ARGS_COUNT -le $MIN_FILES ] ; then
		echo "Замало файлів. Знайдено ${ARGS_COUNT}, а потрібно як мінімум ${MIN_FILES}" >&2
	else
		echo "Good: $ARGS_COUNT files"
	fi
	echo "$@"
}

makefiles(){
	DEFAULT_FILES=3
	COUNTER="${1-${DEFAULT_FILES}}"
	for i in $(seq 1 ${COUNTER})
	 do
			#continue
			echo "$DIRECTORY/file${i}.dat"
		 dd if=/dev/urandom of="$DIRECTORY/file${i}.dat" bs=1 count=$RANDOM 2> /dev/null
	done
}
makefiles 5
exit 0
files=()
while IFS= read -r -d $'\0' ; do
	array+=("${REPLY}")
done < <(find ${DIRECTORY}/* -maxdepth 0 -type f -print0)

echo 0: ${array[0]}
echo 1: ${array[1]}
echo 2: ${array[2]}
echo 3: ${array[3]}
echo all: ${array[@]}
echo count: ${#array[@]}

exit 0
find ${DIRECTORY}/* -maxdepth 0 -type f -print0 | bash -c 'xargs -0 copy_to_remotedir' 
cat <<EOF | ssh remote_host bash
	if [ ! -e ${REMOTE_DIRECTORY} ] ; then
		mkdir -pv ${REMOTE_DIRECTORY}
	else
		if [ ! -d ${REMOTE_DIRECTORY} ] ; then
			echo "Віддалений об'єкт не є каталогом. Завершення роботи" >&2
			exit 1
		fi
	fi
EOF
