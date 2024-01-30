# Dockerfile for Wisecow Application
FROM alpine:latest

RUN apk --no-cache add fortune netcat-openbsd wget build-base perl bash

# Download and install cowsay
RUN wget -O cowsay.tar.gz https://github.com/tnalpgge/rank-amateur-cowsay/archive/master.tar.gz && \
    tar -xzf cowsay.tar.gz && \
    cd rank-amateur-cowsay-master && \
    ./install.sh /usr/local

COPY wisecow.sh /wisecow.sh
RUN chmod +x /wisecow.sh

EXPOSE 4499
ENTRYPOINT ["/bin/sh", "-c", "/wisecow.sh"]
