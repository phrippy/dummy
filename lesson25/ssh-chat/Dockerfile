FROM golang:alpine as builder
WORKDIR /src/
RUN apk add git make openssh
RUN git clone https://github.com/shazow/ssh-chat.git
RUN cd ssh-chat && make build
RUN ssh-keygen -f ./id_rsa -P ''

FROM alpine:edge
WORKDIR /app/
COPY --from=builder /src/id_rsa /src/id_rsa.pub /src/ssh-chat/ssh-chat /app/
CMD ./ssh-chat --verbose --identity=id_rsa --bind ":22"
