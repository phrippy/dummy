FROM alpine:latest
RUN apk add --no-cache nginx
COPY nginx.conf /etc/nginx/
COPY index.html /usr/share/nginx/html/
ENTRYPOINT ["nginx"]
