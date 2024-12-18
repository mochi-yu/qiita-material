#include <arpa/inet.h>
#include <openssl/err.h>
#include <openssl/ssl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

void keylog_callback(const SSL *ssl, const char *line) {
  FILE *fp;

  fp = fopen("keylog.log", "a");
  if (fp == NULL) {
    fprintf(stderr, "Can't open keylog fil.\n");
    return;
  }

  fprintf(fp, "%s\n", line);

  fclose(fp);
}

int main(int argc, char *argv[]) {
  // SSL_CTXの作成
  SSL_CTX *ctx = NULL;
  ctx = SSL_CTX_new(TLS_client_method());
  if (ctx == NULL) {
    printf("Failed to create the SSL_CTX\n");
    return EXIT_FAILURE;
  }

  // サーバ証明書検証の設定
  // FIXME: 検証用に`SSL_VERIFY_NONE`で証明書の検証を行わないよう設定
  SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL);

  // キーログファイルの記録用コールバックを設定
  SSL_CTX_set_keylog_callback(ctx, keylog_callback);

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

    // 認証エラーの場合は原因を出力する
    if (SSL_get_verify_result(ssl) != X509_V_OK)
      printf("Verify error: %s\n",
             X509_verify_cert_error_string(SSL_get_verify_result(ssl)));

    close(sock);
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return EXIT_FAILURE;
  }

  // サーバにデータを送る
  const char *message = "Hello, TLS!!";
  SSL_write(ssl, message, strlen(message));
  printf("Send message to server\n");

  // サーバからデータを受信する
  char buff[256] = {};
  SSL_read(ssl, buff, sizeof(buff));
  printf("Recive message from server: \"%s\"\n", buff);

  // クリーンアップ処理
  SSL_shutdown(ssl);
  close(sock);
  SSL_free(ssl);
  SSL_CTX_free(ctx);

  return EXIT_SUCCESS;
}
