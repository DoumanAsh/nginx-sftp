# nginx-sftp

[![Build](https://github.com/DoumanAsh/nginx-sftp/actions/workflows/docker-image.yml/badge.svg)](https://github.com/DoumanAsh/nginx-sftp/actions/workflows/docker-image.yml)
[![Hub](https://img.shields.io/badge/Docker-Hub-2496ed.svg)](https://hub.docker.com/r/douman/nginx-sftp/tags)

Simple docker container to run sftp server with nginx serving static files side by side based on [linuxserver/docker-openssh-server](https://github.com/linuxserver/docker-openssh-server)

## Environment variables

- `PUID` - Configures user id;
- `PGID` - Configures group id of the above user;
- `USER_NAME` - Configures user name. Defaults to `dev`;
- `SUDO_ACCESS` - Configures whether to enable sudo on account or not;
- `USER_PASSWORD` - Specifies password of the user account;
- `PASSWORD_ACCESS` - Specifies whether to allow password access over ssh;
- `SSH_PORT` - Configures port for SSH service to listen on. Defaults to 2222;
- `HTTP_PORT` - Configures port for default HTTP service to listen on. Defaults to 8080;
- `HTTP_SERVE_ROUTE` - Configures http route to serve `$HTTP_SERVE_FOLDER` in default HTTP service. Defaults to `/static`;
- `HTTP_SERVE_FOLDER` - Configures folder to serve in default HTTP service. Defaults to None;
- `HTTP_SERVE_HTPASSWD` - Specifies path to the basic auth credentials. Defaults to `/config/nginx/.htpasswd`
- `UMASK` - Specifies umask value for SFTP service;
- `PUBLIC_KEY` - Specifies public key to authorize access from;
- `PUBLIC_KEY_FILE` - Specifies path to the public key to authorize access from;

### Configuration customization

Folder `/config` is created to be used for all customizations
You can mount it to persist stuff

- SSH service
    - `/config/sshd/sshd_config.d` - Folder can be mounted to provide extra customization
- HTTP service
    - `/config/nginx/http.d/` - Folder can be mounted to provider nginx HTTP sites. If none exists, default is created as `/config/nginx/http.d/default.conf`
    - `/config/nginx/conf.d/` - Folder can be mounted to provider nginx general configuration
    - `/config/nginx/.htpasswd/` - File can be mounted to provide credentials
