#include <arpa/inet.h>
#include <netinet/in.h>
#include <openssl/err.h>
#include <openssl/ssl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

int main(int argc, char const *argv[]) {
  // SSL_CTXを作成する
  SSL_CTX *ctx = NULL;
  ctx = SSL_CTX_new(TLS_server_method());
  if (ctx == NULL) {
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  // 証明書と秘密鍵の読み込み
  if (SSL_CTX_use_certificate_file(ctx, "./server.crt", SSL_FILETYPE_PEM) <=
      0) {
    SSL_CTX_free(ctx);
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  if (SSL_CTX_use_PrivateKey_file(ctx, "./server.key", SSL_FILETYPE_PEM) <= 0) {
    SSL_CTX_free(ctx);
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  // 受け入れ用BIOの設定
  BIO *acceptor_bio;
  const char *hostport = "12345";
  acceptor_bio = BIO_new_accept(hostport);
  if (acceptor_bio == NULL) {
    SSL_CTX_free(ctx);
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  BIO_set_bind_mode(acceptor_bio, BIO_BIND_REUSEADDR);
  if (BIO_do_accept(acceptor_bio) <= 0) {
    SSL_CTX_free(ctx);
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
  }

  // サーバーループ
  printf("Start Server:\n");
  for (;;) {
    BIO *client_bio;
    SSL *ssl;
    unsigned char buf[8192];
    size_t nread;
    size_t nwritten;
    size_t total = 0;

    // クライアントの接続を待ち続ける
    if (BIO_do_accept(acceptor_bio) <= 0) {
      continue;
    }

    // 新しいクライアント接続がきたら、SSLハンドシェイクの準備をする
    client_bio = BIO_pop(acceptor_bio);
    printf("New client connection accepted\n");

    if ((ssl = SSL_new(ctx)) == NULL) {
      ERR_print_errors_fp(stderr);
      printf("Error creating SSL handle for new connection\n");
      BIO_free(client_bio);
      continue;
    }
    SSL_set_bio(ssl, client_bio, client_bio);

    // SSLハンドシェイクを行う
    if (SSL_accept(ssl) <= 0) {
      ERR_print_errors_fp(stderr);
      printf("Error performing SSL handshake with client\n");
      SSL_free(ssl);
      continue;
    }

    // クライアントとの接続が閉じられるまで、クライアントの入力をエコーバックする
    while (SSL_read_ex(ssl, buf, sizeof(buf), &nread) > 0) {
      if (SSL_write_ex(ssl, buf, nread, &nwritten) > 0 && nwritten == nread) {
        total += nwritten;
        continue;
      }
      printf("Error echoing client input\n");
      break;
    }
    printf("Client connection closed, %zu bytes sent\n", total);
    SSL_free(ssl);
  }

  // このプログラムでは実行されないが、なんらかのサーバループを停止する処理を実装して、これを呼び出す
  SSL_CTX_free(ctx);
  return EXIT_SUCCESS;
}
