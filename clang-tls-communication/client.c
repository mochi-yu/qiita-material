#include <arpa/inet.h>
#include <openssl/err.h>
#include <openssl/ssl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  // SSL_CTXの作成
  SSL_CTX *ctx = NULL;
  ctx = SSL_CTX_new(TLS_client_method());
  if (ctx == NULL) {
    printf("Failed to create the SSL_CTX\n");
    return EXIT_FAILURE;
  }

  // サーバ証明書検証の設定
  SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
  if (!SSL_CTX_set_default_verify_paths(ctx)) {
    printf("Failed to set the default trusted certificate store\n");
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  // SSLオブジェクトの作成
  SSL *ssl = NULL;
  ssl = SSL_new(ctx);
  if (ssl == NULL) {
    printf("Failed to create the SSL object\n");
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  // ソケットの作成
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    printf("Failed to create socket\n");
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  struct sockaddr_in server;
  server.sin_family = AF_INET;
  server.sin_addr.s_addr = inet_addr("127.0.0.1");
  server.sin_port = htons(12345);

  if (connect(sock, (struct sockaddr *)&server, sizeof(server)) == -1) {
    printf("failed to connect to the server\n");
    close(sock);
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  if (!SSL_set_fd(ssl, sock)) {
    perror("Error: SSL_set_fd()\n");
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  // TLSハンドシェイクを行う
  if (SSL_connect(ssl) < 1) {
    printf("Failed to tls hancshake\n");
    ERR_print_errors_fp(stderr);

    if (SSL_get_verify_result(ssl) != X509_V_OK)
      printf("Verify error: %s\n",
             X509_verify_cert_error_string(SSL_get_verify_result(ssl)));

    close(sock);
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  // FIXME:
  printf("Cipher: %s\n", SSL_get_cipher(ssl));
  printf("Version: %s\n", SSL_get_version(ssl));

  // サーバにデータを送る
  const char *message = "Hello, TLS!!";
  SSL_write(ssl, message, strlen(message));
  printf("Sent message to server\n");

  // サーバからデータを受信する
  char buff[256] = {};
  SSL_read(ssl, buff, sizeof(buff));
  printf("Recive message from server: \"%s\"", buff);

  // クリーンアップ処理
  if (SSL_shutdown(ssl) < 1) {
    printf("Failed to shutdown ssl\n");
    close(sock);
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  close(sock);
  SSL_free(ssl);
  SSL_CTX_free(ctx);

  return EXIT_SUCCESS;
}
