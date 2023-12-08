FROM golang:1.21

LABEL version="0.0.1"
LABEL maintainer="Ain Tohvri <ain@flashbit.net>"

RUN go install github.com/ysugimoto/falco/cmd/falco@latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
