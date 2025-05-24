.PHONY: gen-crt
gen-crt:
	openssl genrsa 2048 > server.key
	openssl req -x509 -new -nodes -key server.key -subj "/CN=server" -days 10000 -out server.crt

.PHONY: build
build:
	gcc client.c -o client -lcrypto -lssl
	gcc server.c -o server -lcrypto -lssl

.PHONY: capture
capture:
	tshark -i any -w out.pcap -f "port 12345"
