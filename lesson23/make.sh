#!/bin/bash
(
cat head.md
echo
echo '```bash'
cat keygen.sh
echo '```'
echo
cat keygen.md
echo
echo '```bash'
cat server.conf
echo '```'
echo
cat client.md
echo
echo '```bash'
cat client.conf
echo '```'
) > lesson23.md
