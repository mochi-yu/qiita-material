package main

import (
	"bufio"
	"crypto/tls"
	"log"
	"net"
)

func main() {
	cer, err := tls.LoadX509KeyPair("server.crt", "server.key")
	if err != nil {
		log.Fatal("loadkeys: ", err)
	}

	config := &tls.Config{Certificates: []tls.Certificate{cer}}
	ln, err := tls.Listen("tcp", ":12345", config)
	if err != nil {
		log.Fatal("listen: ", err)
	}
	defer ln.Close()

	log.Println("Start Server:")

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal("accept: ", err)
		}

		log.Println("New client connection accepted")
		go func(conn net.Conn) {
			s := bufio.NewScanner(conn)
			for s.Scan() {
				msg := s.Text()
				log.Printf("Accept Message: `%s`", msg)
				_, err := conn.Write([]byte(msg))
				if err != nil {
					log.Print("write: ", err)
				}
			}
			conn.Close()
			log.Println("Client connection closed")
		}(conn)
	}
}
