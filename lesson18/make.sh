#!/bin/bash
cd "$(dirname $0)"
(cat head.md
echo
echo '```bash'
cat lib.sh
echo '```'
echo
cat pretext.sh
echo
echo '```bash'
cat task.sh
echo '```'
echo
cat footer.sh) > lesson18.md
msg='upd'
if [ ! -z "$1" ] ; then
	msg="$1"
fi
git commit -am "$msg"
git push
