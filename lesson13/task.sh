#!/bin/bash
DIRECTORY="$HOME/task"
if [[ ! -e "${DIRECTORY}" ]] ; then
  mkdir -pv "${DIRECTORY}"
fi

if [[ ! -d "${DIRECTORY}" ]] ; then
 echo "${DIRECTORY} is not directory!"
 echo "Aborting..."
 exit 1
fi

for i in $(groups)
  do
    mkdir -pv "${DIRECTORY}/$i"
done

for i in "${DIRECTORY}"/*
  do
    sudo chown -v root:$(basename "$i") "${i}"
    sudo chmod -v 607 "${i}"
done

sudo chmod -v g+s "${DIRECTORY}"
sudo chmod -v o+t "${DIRECTORY}"

touch "${DIRECTORY}/testfile"
ln --physical --verbose "${DIRECTORY}/testfile" "${DIRECTORY}/hardlink_file"
ln --symbolic --relative --verbose "${DIRECTORY}/testfile" "${DIRECTORY}/softlink_file"

for i in {0..9}
  do
    dd if=/dev/urandom of="$DIRECTORY/file${i}.dat" bs=1 count=$RANDOM
done

cd "${DIRECTORY}"/..
tar czf "${DIRECTORY}/archive.tar.gz" $(basename $DIRECTORY)/*.dat
