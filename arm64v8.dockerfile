# :: Arch
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM golang:1.21-alpine3.19 as build
  ENV BUILD_VERSION=v1.15.5
  ENV BUILD_DIR=/go/vault

  RUN set -ex; \
    apk add --update --no-cache \
      bash \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      nodejs \
      bower \
      yarn \
      npm \
      go-bindata \
      go-bindata-assetfs \
      g++ \
      openssh \
      git; \
    git clone https://github.com/hashicorp/vault.git; \
    cd ${BUILD_DIR}; \
    git checkout ${BUILD_VERSION};

  #COPY ./build /

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    make bootstrap;\
    BUILD_TAGS='vault ui' XC_OSARCH='linux/arm64' make static-dist bin;
    
# :: Header
  FROM 11notes/alpine:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /go/bin/vault /usr/local/bin
  ENV APP_NAME="hashicorpvault"
  ENV APP_ROOT=/vault

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/log; \
      mkdir -p ${APP_ROOT}/ssl; \
      apk --no-cache add \
        openssl \
        libcap; \
      apk --no-cache upgrade;

    RUN /usr/sbin/setcap cap_ipc_lock=+ep /usr/local/bin/vault

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin;

    RUN set -ex; \
      touch /etc/ssl/certs/vault.crt;

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        /etc/ssl/certs/vault.crt \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/ssl"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]