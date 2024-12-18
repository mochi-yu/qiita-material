.PHONY: gen/ca-crt gen/server-crt
gen/ca-crt:
	openssl genrsa 2048 > ca.key
	openssl req -new -key ca.key -subj "/CN=rootca" > ca.csr
	openssl x509 -req -in ca.csr -signkey ca.key -days 10000 -out ca.crt
gen/server-crt:
	openssl genrsa 2048 > server.key
	openssl req -new -key server.key -subj "/CN=servername" > server.csr
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -out server.crt

.PHONY: build
build:
	gcc -I /usr/include client.c -o client -lcrypto -lssl
	gcc -I /usr/include server.c -o server -lcrypto -lssl
