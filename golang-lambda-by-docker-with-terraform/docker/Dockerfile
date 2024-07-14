################## ビルドステージ ##################
FROM golang:1.22 as build

WORKDIR /app

COPY ./src/go.mod ./src/go.sum ./
RUN go mod download

COPY ./src .
RUN go build -tags lambda.norpc -o main main.go

################## 実行ステージ ##################
FROM public.ecr.aws/lambda/provided:al2023

COPY --from=build /app/main ./main
ENTRYPOINT [ "./main" ]
