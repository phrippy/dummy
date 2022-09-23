#!/bin/bash
(
cat head.md
echo
echo '```Dockerfile'
cat Dockerfile
echo '```'
echo
) > lesson24.md
