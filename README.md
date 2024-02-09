![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - HashiCorp Vault
![size](https://img.shields.io/docker/image-size/11notes/hashicorp-vault/1.15.5?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/hashicorp-vault/1.15.5?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/hashicorp-vault?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-hashicorp-vault?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-hashicorp-vault?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/hashicorp-vault?color=e6a50e)

**Run HashiCorp Vault in the most secure way**

# SYNOPSIS
What can I do with this? This image will provide you by default with the most secure way to run HashiCorp Vault. It’s compiled from source and comes by default with all settings applied to harden it.

# VOLUMES
* **/vault/etc** - Directory of config.hcl
* **/vault/var** - Directory of file or raft backend

# RUN
```shell
docker run --name hashicorp-vault \
  -v .../etc:/vault/etc \
  -v .../var:/vault/var \
  -d 11notes/hashicorp-vault:[tag]
```

# EXAMPLES
## config /vault/etc/config.hcl
```hcl
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
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /vault | home directory of user docker |
| `config` | /vault/etc/config.hcl | config |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/node:stable](https://hub.docker.com/r/11notes/node)

# BUILT WITH
* [hashicorp vault](https://www.vaultproject.io)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    