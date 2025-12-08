FROM golang:latest

LABEL org.opencontainers.image.authors="Ain Tohvri <ain@flashbit.net>" \
      org.opencontainers.image.version="0.1.0"

RUN go install github.com/ysugimoto/falco/cmd/falco@latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
