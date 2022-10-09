#!/bin/bash
docker build -t ssh-chat .
DEFAULT_KEY=/key/id_rsa
DEFAULT_PORT=12345
KEY=${1:-${DEFAULT_KEY}}
PORT=${2:-${DEFAULT_PORT}}
docker run -d --rm -v /root/.ssh:/key -e KEY=$KEY -e PORT=$PORT -p 2222:$PORT --name ssh-chat ssh-chat
