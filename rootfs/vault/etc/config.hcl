ui = true

storage "file" {
  path = "/vault/var"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 0
  tls_cert_file = "/vault/ssl/default.crt"
  tls_key_file  = "/vault/ssl/default.key"
  tls_disable_client_certs = "true"
}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"