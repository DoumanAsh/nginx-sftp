#!/usr/bin/with-contenv sh

USER_NAME=${USER_NAME:-defaultuser}
PUID=${PUID:-911}
PGID=${PGID:-911}

echo "### Setup user ${USER_NAME} with uid=${PUID} and gid=${PGID}"
adduser -D -u $PUID $USER_NAME
#addgroup -g $PGID $USER_NAME

# set password for user to unlock it and set sudo access
sed -i "/${USER_NAME} ALL.*/d" /etc/sudoers
if [[ "$SUDO_ACCESS" == "true" ]]; then
    if [[ -n "$USER_PASSWORD" ]]; then
        echo "${USER_NAME} ALL=(ALL) ALL" >> /etc/sudoers
        echo "#### sudo is enabled with password."
    else
        echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        echo "#### sudo is enabled without password."
    fi
else
    echo "#### sudo is disabled."
fi

USER_PASSWORD=${USER_PASSWORD:-$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-8}";echo;)}
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# Setup config folder
mkdir -p /config/sshd
mkdir -p /config/.ssh
mkdir -p /config/logs/sshd
mkdir -p /config/logs/nginx

if [ ! -f /config/nginx/mime.types ]; then
    cp /etc/nginx/mime.types /config/nginx/mime.types
fi

if [ ! -f /config/nginx/nginx.conf ]; then
    cp /etc/nginx/nginx.conf /config/nginx/nginx.conf
fi

mkdir -p /config/nginx/conf.d
mkdir -p /config/nginx/http.d
if [ ! -d /config/nginx/modules ]; then
    echo "### Generating SSH keys"
    mkdir -p /config/nginx/modules
    cp -rf /etc/nginx/modules /config/nginx/modules
fi

if [ ! -d /config/ssh_host_keys ]; then
    mkdir -p /config/ssh_host_keys
    ssh-keygen -A
    cp /etc/ssh/ssh_host_* /config/ssh_host_keys
fi

if [[ ! -f /config/sshd/sshd_config ]]; then
    cp /etc/ssh/sshd_config /config/sshd/sshd_config
    echo "PidFile /tmp/sshd.pid" >> /config/sshd/sshd_config
fi

# Enable sshd_config.d if mounted
if [[ -d /config/sshd/sshd_config.d ]]; then
    sed -i 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/Include \/config\/sshd\/sshd_config.d\/\*.conf/' /config/sshd/sshd_config
    sed -i '/Include \/config\/sshd\/sshd_config.d/s/^#*//' /config/sshd/sshd_config
fi

# display SSH host public key(s)
echo "### SSH host public key(s):"
cat /config/ssh_host_keys/ssh_host_*.pub

# customize port
if [[ -n "${SSH_PORT}" ]]; then
    sed -i "s/^#Port [[:digit:]]\+/Port ${SSH_PORT}"/ /config/sshd/sshd_config
    sed -i "s/^Port [[:digit:]]\+/Port ${SSH_PORT}"/ /config/sshd/sshd_config
    echo "### sshd is listening on port ${SSH_PORT}"
else
    sed -i "s/^#Port [[:digit:]]\+/Port 2222"/ /config/sshd/sshd_config
    sed -i "s/^Port [[:digit:]]\+/Port 2222"/ /config/sshd/sshd_config
    echo "### sshd is listening on port 2222"
fi

# password access
if [[ "$PASSWORD_ACCESS" == "true" ]]; then
    sed -i '/^#PasswordAuthentication/c\PasswordAuthentication yes' /config/sshd/sshd_config
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication yes' /config/sshd/sshd_config
    chown root:"${USER_NAME}" /etc/shadow
    echo "### User/password ssh access is enabled."
else
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication no' /config/sshd/sshd_config
    chown root:root /etc/shadow
    echo "### User/password ssh access is disabled."
fi

# set umask for sftp
UMASK=${UMASK:-022}
sed -i "s|/usr/lib/ssh/sftp-server$|/usr/lib/ssh/sftp-server -u ${UMASK}|g" /config/sshd/sshd_config

# set key auth in file
if [[ ! -f /config/.ssh/authorized_keys ]]; then
    touch /config/.ssh/authorized_keys
fi

if [[ -n "$PUBLIC_KEY" ]]; then
    if [[ ! grep -q "${PUBLIC_KEY}" /config/.ssh/authorized_keys ]]; then
        echo "$PUBLIC_KEY" >> /config/.ssh/authorized_keys
        echo "### Public key from env variable added"
    fi
fi

if [[ -n "$PUBLIC_KEY_FILE" ]] && [[ -f "$PUBLIC_KEY_FILE" ]]; then
    PUBLIC_KEY2=$(cat "$PUBLIC_KEY_FILE")
    if [[! grep -q "$PUBLIC_KEY2" /config/.ssh/authorized_keys]]; then
        echo "$PUBLIC_KEY2" >> /config/.ssh/authorized_keys
        echo "### Public key from file added"
    fi
fi

# Setup nginx
if [ ! -n "$(ls -A -- "/config/nginx/http.d/")" ]; then
    HTTP_PORT=${HTTP_PORT:-8080}
    echo "### Nginx has no http site"
cat > /config/nginx/http.d/default.conf << EOF
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;

    # health check
    location / {
        return 200;
    }

    # deny hidden files
    location ~/\. {
        deny all;
    }
EOF

env
if [[ -n "$HTTP_SERVE_FOLDER" ]] && [[ -d "$HTTP_SERVE_FOLDER" ]]; then
    echo "### Nginx serves $HTTP_SERVE_FOLDER..."
    HTTP_SERVE_ROUTE=${HTTP_SERVE_ROUTE:-/static}
echo "    location $HTTP_SERVE_ROUTE {" >> /config/nginx/http.d/default.conf

    HTTP_SERVE_HTPASSWD=${HTTP_SERVE_HTPASSWD:-/config/nginx/.htpasswd}
    if [[ -f "$HTTP_SERVE_HTPASSWD" ]]; then
    echo "### Nginx enables basic auth"
cat >> /config/nginx/http.d/default.conf << EOF
        auth_basic           "Restricted File Area";
        auth_basic_user_file $HTTP_SERVE_HTPASSWD;
EOF
    fi

cat >> /config/nginx/http.d/default.conf << EOF
        alias $HTTP_SERVE_FOLDER;
        autoindex on;
        autoindex_format html;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
EOF

fi

echo "}" >> /config/nginx/http.d/default.conf

fi

# permissions
chown -R "${USER_NAME}":"${USER_NAME}" /config
chmod go-w /config
chmod 700 /config/.ssh
chmod 600 /config/.ssh/authorized_keys

chown -R root:"${USER_NAME}" /config/sshd
chmod 750 /config/sshd
chmod 640 /config/sshd/sshd_config
