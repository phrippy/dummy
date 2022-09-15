#!/bin/bash
(
cat head.md
echo
echo '```bash'
cat keygen.sh
echo '```'
echo
) > lesson23.md
