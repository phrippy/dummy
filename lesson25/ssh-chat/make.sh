#!/bin/bash
(
cat head.md
echo
echo '```Dockerfile'
cat Dockerfile
echo '```'
cat build.md
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
cat petstore.md
echo
echo '```Dockerfile'
cat ../Dockerfile
echo '```'
echo
cat footer.md
) > lesson25.md

git commit -am 'upd' && git push
