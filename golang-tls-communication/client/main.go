package main

import (
	"crypto/tls"
	"log"
	"os"
)

func main() {
	w, err := os.Create("keylog.log")
	if err != nil {
		log.Fatal("open file: ", err)
	}

	conf := &tls.Config{
		InsecureSkipVerify: true, // 検証のためにTLSの検証をスキップ
		KeyLogWriter:       w,
	}

	conn, err := tls.Dial("tcp", "127.0.0.1:12345", conf)
	if err != nil {
		log.Fatal("dial: ", err)
	}
	defer conn.Close()

	_, err = conn.Write([]byte("Hello, golang TLS!!\n"))
	if err != nil {
		log.Fatal("write: ", err)
	}

	buf := make([]byte, 100)
	n, err := conn.Read(buf)
	if err != nil {
		log.Fatal("read: ", err)
	}

	log.Printf("Accept Message: `%s`", buf[:n])
}
