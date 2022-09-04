#!/bin/bash
SCRIPT_DIR="$(dirname $(realpath $0))"
source "${SCRIPT_DIR}/lib.sh"
if [ $SCRIPT_DIR == $DIRECTORY ] ; then
	DIRECTORY="$DIRECTORY/workdir"
	mkdir -v "$DIRECTORY"
fi
get_local_files
copy_to_remotedir
list_remote_files
rm_local_files
makefiles_remote 2
