# nginx-sftp

[![Build](https://github.com/DoumanAsh/nginx-sftp/actions/workflows/docker-image.yml/badge.svg)](https://github.com/DoumanAsh/nginx-sftp/actions/workflows/docker-image.yml)
[![Hub](https://img.shields.io/badge/Docker-Hub-2496ed.svg)](https://hub.docker.com/r/douman/nginx-sftp/tags)

Simple docker container to run sftp server with nginx serving static files side by side inspired by [linuxserver/docker-openssh-server](https://github.com/linuxserver/docker-openssh-server) but with minimal amount of fluff

## Versioning

- `nginx-sftp:latest` - Uses latest stable alpine image. Can be change with release of new stable alpine
- `nginx-sftp:<alpine version>` - Use specific alpine version for stability. Always matches specific alpine version

As container uses stable alpine image following packages are used by `latest` image:

- [nginx](https://pkgs.alpinelinux.org/packages?name=nginx&branch=v3.24&repo=&arch=x86_64&origin=&flagged=&maintainer=)
- [openssh](https://pkgs.alpinelinux.org/packages?name=openssh-sftp-server&branch=v3.24&repo=&arch=x86_64&origin=&flagged=&maintainer=)

## Environment variables

- `PUID` - Configures user id. Defaults to 911;
- `PGID` - Configures group id of the above user. Defaults to 911;
- `USER_NAME` - Configures user name. Defaults to `defaultuser`;
- `USER_CWD` - Customizes user's initial folder. If no folder exists, creates home like folder. Defaults to `/home/$USER_NAME`;
- `SUDO_ACCESS` - Configures whether to enable sudo on account or not;
- `USER_PASSWORD` - Specifies password of the user account;
    - This password is only used to secure SFTP access
    - To protect HTTP endpoint you should mount `/config/nginx/.htpasswd`
- `PASSWORD_ACCESS` - Specifies whether to allow password access over ssh.;
- `SSH_PORT` - Configures port for SSH service to listen on. Defaults to `2222`;
- `HTTP_PORT` - Configures port for default HTTP service to listen on. Defaults to 8080;
- `HTTP_SERVE_ROUTE` - Configures http route to serve `$HTTP_SERVE_FOLDER` in default HTTP service. Defaults to `/static`;
- `HTTP_SERVE_FOLDER` - Configures folder to serve in default HTTP service. Defaults to None;
- `HTTP_SERVE_HTPASSWD` - Specifies path to the basic auth credentials. Defaults to `/config/nginx/.htpasswd`
- `HTTP_SERVE_UPLOAD_ROUTE` - Configures http route to allow upload into `$HTTP_SERVE_FOLDER`. Defaults to None;
- `UMASK` - Specifies umask value for SFTP service. Defaults to `022`;
- `PUBLIC_KEY` - Specifies public key to authorize access from. Optional;
- `PUBLIC_KEY_FILE` - Specifies path to the public key to authorize access from. Optional;

### Configuration customization

Folder `/config` is created to be used for all customizations
You can mount it to persist your stuff

- SSH service
    - `/config/sshd/sshd_config.d` - Folder can be mounted to provide extra customization
- HTTP service
    - `/config/nginx/http.d/` - Folder can be mounted to provider nginx HTTP sites. If none exists, default is created as `/config/nginx/http.d/default.conf`
    - `/config/nginx/conf.d/` - Folder can be mounted to provider nginx general configuration
    - `/config/nginx/.htpasswd` - File can be mounted to provide credentials

## SSH access

Unless you specify `PASSWORD_ACCESS=true` and provide `USER_PASSWORD` you can only connect via `ssh -i <your private key> $USER_NAME@$SERVER_HOST:$SSH_PORT`

Which requires that you provide `PUBLIC_KEY` or mount public key to be accessible within container via environment variable `PUBLIC_KEY_FILE`

## HTTP access

Static files are served via path provided in `$HTTP_SERVE_ROUTE` which means you can access files via `http://$SERVER_HOST/$HTTP_SERVE_ROUTE`
But unless you specify `HTTP_SERVE_FOLDER`, you will not be able to view files as by default it defaults to no folder, which means nothing is served

Optionally you can enable file upload via `HTTP_SERVE_UPLOAD_ROUTE` which enables `http://$SERVER_HOST/$HTTP_SERVE_UPLOAD_ROUTE` to serve for the purpose of data modification
via http and/or dav methods `PUT`, `DELETE`, `MKCOL,` `COPY` `MOVE`

### Health check

Aside from optional static files mounted via `HTTP_SERVE_FOLDER` and served via `HTTP_SERVE_ROUTE` nginx server will expose `/` endpoint for purposes of health check so you can always verify nginx is up via `curl -v http://$SERVER_HOST/`
