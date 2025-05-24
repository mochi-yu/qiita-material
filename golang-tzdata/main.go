package main

import (
	"fmt"
	"time"
)

func main() {
	loc, err := time.LoadLocation("Asia/Tokyo")
	if err != nil {
		fmt.Println("!!ERROR!! ", err)
		return
	}

	fmt.Println("Time: ", time.Now().In(loc))
}
