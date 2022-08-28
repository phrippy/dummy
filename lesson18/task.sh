#!/bin/bash
DIRECTORY=${PWD}
REMOTE_DIRECTORY='~/remote'
MIN_FILES=3
for i in {1..3}
  do
    dd if=/dev/urandom of="$DIRECTORY/file${i}.dat" bs=1 count=$RANDOM 2> /dev/null
done
find ${DIRECTORY}/* -maxdepth 0 -type f -print0 > /tmp/tempfile
FILES_COUNT=$(cat /tmp/tempfile | xargs -0 -n1 | wc -l)
if [ ${FILES_COUNT} -lt ${MIN_FILES} ] ; then
	echo "Замало файлів. Знайдено ${FILES_COUNT}, а потрібно як мінімум ${MIN_FILES}" >&2
	exit 1
else
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
fi
cat /tmp/tempfile | hexdump -C
