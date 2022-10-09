#!/bin/bash
(
echo head.md
echo
echo '```Dockerfile'
cat Dockerfile
echo '```'
echo build.md
echo
echo '```bash'
cat build-and-run.sh
echo '```'
echo
cat connect.md 
echo
echo '```bash'
cat connect.sh
echo '```'
echo
cat footer.md
echo
echo '```Dockerfile'
cat ../Dockerfile
echo '```'
) > lesson25.md

git commit -am 'upd' && git push
