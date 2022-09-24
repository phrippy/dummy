FROM alpine:3.16.2
MAINTAINER Serhii Hordiienko <phrippy2@gmail.com>
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/v3.16/main nginx=1.22.0-r1
COPY nginx.conf /etc/nginx/
COPY index.html /usr/share/nginx/html/
CMD ["nginx"]
