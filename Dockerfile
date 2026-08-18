FROM golang:1.26.6

LABEL org.opencontainers.image.authors="Ain Tohvri <ain@flashbit.net>" \
      org.opencontainers.image.version="1.1.1"

RUN go install github.com/ysugimoto/falco/cmd/falco@v1.21.1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
