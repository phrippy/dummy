FROM golang:alpine3.16 as builder
WORKDIR /src/
RUN apk add git make openssh
RUN git clone https://github.com/shazow/ssh-chat.git
RUN cd ssh-chat && make build
RUN ssh-keygen -f ./id_rsa -P ''

FROM alpine:3.16.2
WORKDIR /app/
ENV KEY=id_rsa
ENV KEYPATH=/src/${KEY}
ARG PORT=22
COPY --from=builder $KEYPATH ${KEYPATH}.pub /src/ssh-chat/ssh-chat ./
RUN echo "./ssh-chat --verbose --identity=$KEY --bind \":${PORT}\"" > run && chmod +x run
ENTRYPOINT ["sh"]
CMD ["run"]
