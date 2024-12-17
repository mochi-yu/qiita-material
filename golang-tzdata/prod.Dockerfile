################## ビルドステージ ##################
FROM golang:1.23.4-alpine3.21 AS builder

WORKDIR /app

COPY ./main.go .

RUN go build -tags timetzdata -o main main.go

################## 実行ステージ ##################
FROM alpine:3.21
WORKDIR /app

# ビルドしたバイナリをコピー
COPY --from=builder /app/main .

CMD /app/main
