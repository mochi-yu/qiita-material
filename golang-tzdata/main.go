package main

import (
	"log"
	"time"
)

func main() {
	loc, err := time.LoadLocation("Asia/Tokyo")
	if err != nil {
		log.Fatal("!!ERROR!! ", err)
	}

	log.Print(time.Now().In(loc))
}
