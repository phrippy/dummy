#!/bin/bash
cd `dirname $0`
(
	cat head.md
	echo
	echo '# Скрипт створення користувача'
	echo '```bash'
	cat user.sh
	echo '```'
	echo
	echo '# Скрипт створення каталогу task'
	echo
	echo '```bash'
	cat task.sh
	echo '```'
) > lesson13.md
