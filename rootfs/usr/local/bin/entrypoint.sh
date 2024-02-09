#!/bin/ash
  set -e
  ulimit -c 0

  if [ -z "${1}" ]; then

    if [ ! -f "${APP_ROOT}/ssl/default.crt" ]; then
      if [ ! -f "${APP_ROOT}/ssl/ca.crt" ]; then
        elevenLogJSON info "ssl: no ca defined, creating ca"

        openssl req -x509 -newkey rsa:4096 -config /etc/ssl/ca.conf -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=CA" \
          -keyout "${APP_ROOT}/ssl/ca.key" \
          -out "${APP_ROOT}/ssl/ca.crt" \
          -days 3650 -nodes -sha256 &> /dev/null
      fi

      cat ${APP_ROOT}/ssl/ca.crt > /etc/ssl/certs/vault.crt

      openssl req -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=SERVER" \
          -keyout "${APP_ROOT}/ssl/default.key" \
          -out "${APP_ROOT}/ssl/default.csr" \
          -days 3650 -nodes -sha256 &> /dev/null

      export SAN="IP:127.0.0.1"

      openssl x509 -req -extfile /etc/ssl/server.ext -in "${APP_ROOT}/ssl/default.csr" -CA "${APP_ROOT}/ssl/ca.crt" -CAkey "${APP_ROOT}/ssl/ca.key" -CAcreateserial \
        -out "${APP_ROOT}/ssl/default.crt" \
        -days 3650 -sha256 &> /dev/null 

      rm "${APP_ROOT}/ssl/default.csr"
    fi

    elevenLogJSON info "starting vault"
    set -- "vault" \
      server \
      -config="${APP_ROOT}/etc/config.hcl" 

  fi

  exec "$@"