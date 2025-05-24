################## ビルドステージ ##################
FROM golang:1.22-alpine as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main main.go

################## 実行ステージ ##################
FROM alpine:3.19
WORKDIR /app

# ビルドしたバイナリをコピー
COPY --from=builder /app/main .

HEALTHCHECK CMD wget --quiet --spider http://localhost:1323/ || exit 1

CMD [ "./main" ]
