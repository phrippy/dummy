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
	cat tail.md
) > lesson13.md
