#!/bin/bash
(
cat head.md
echo
echo '```Dockerfile'
cat Dockerfile
echo '```'
echo
cat conf.md
echo
echo '```Nginx config'
cat nginx.conf
echo '```'
echo
cat html.md
echo
echo '```html'
cat index.html
echo
cat footer.md
) > lesson24.md
