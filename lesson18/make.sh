#!/bin/bash
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
