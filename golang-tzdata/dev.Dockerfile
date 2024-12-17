FROM golang:1.23.4-alpine3.21

WORKDIR /app

COPY ./main.go .
CMD go run main.go
