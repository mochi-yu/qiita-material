package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

type MyResponse struct {
	Message string `json:"msg"`
	Time    string `json:"time"`
}

func HandleRequest(ctx context.Context, event *MyEvent) (*MyResponse, error) {
	if event == nil {
		return nil, fmt.Errorf("received nil event")
	}

	msg := "Hello, " + event.Name + "!"
	res := MyResponse{
		Message: msg,
		Time:    time.Now().String(),
	}
	log.Print(res)

	return &res, nil
}

func main() {
	lambda.Start(HandleRequest)
}
