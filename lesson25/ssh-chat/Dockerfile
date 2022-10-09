FROM golang:alpine3.16 as builder
WORKDIR /src/
RUN apk add --no-cache git make openssh
RUN git clone https://github.com/shazow/ssh-chat.git
RUN cd ssh-chat && make build
RUN ssh-keygen -f ./id_rsa -P ''

FROM alpine:3.16.2
WORKDIR /app/
ENV KEY=/key/id_rsa PORT=22
ARG KEY_FROM=/src/id_rsa
COPY --from=builder /src/ssh-chat/ssh-chat ./
RUN mkdir /key/
COPY --from=builder $KEY_FROM ${KEY_FROM}.pub /key/
ENTRYPOINT ./ssh-chat --identity=$KEY --bind ":${PORT}"
CMD ["--verbose"]
