#!/usr/bin/env ash

# set -x

SSHD_PORT="${SSHD_PORT:-22}"
HOST_KEYS_DIR="${HOST_KEYS_DIR:-/config/host-keys}"
USER_NAME="${USER_NAME:-root}"
PASSWORD="${PASSWORD}"

mkdir -p "$HOST_KEYS_DIR"

if [ "$(find "$HOST_KEYS_DIR" -iname "ssh_host_*" | wc -l)" -lt 1 ]
then
  echo "No hostkeys found. Generating now." >&2
  ssh-keygen -A
  cp /etc/ssh/ssh_host_* "$HOST_KEYS_DIR"
else
  echo "Importing host keys from $HOST_KEYS_DIR" >&2
  cp "${HOST_KEYS_DIR}"/ssh_host_* /etc/ssh
  chown root:root /etc/ssh/ssh_host_*
  chmod 600 /etc/ssh/ssh_host_*
fi

sshd_config_set() {
  local config=/etc/ssh/sshd_config
  local name="$1"
  local value="$2"

  if [ -z "$name" ] || [ -z "$value" ]
  then
    echo "Usage: $0 NAME VALUE"
    return 2
  fi

  sed -i -r "s/^\#?\s*${name}.*$/$name $value/" "$config"
}

update_sshd_config() {
  if [ -n "$PERMIT_ROOT_LOGIN" ]
  then
    sshd_config_set "PermitRootLogin" "$PERMIT_ROOT_LOGIN"
  fi

  if [ "$USER_NAME" != "root" ] && [ -n "$PASSWORD" ]
  then
    sshd_config_set PasswordAuthentication yes
  fi
  # local config_entry
  # local value

  # for config_entry in PermitRootLogin
  # do
  #   value="$(eval "echo \$$(echo $config_entry)")"
  #   if [[ -n "$value" ]]
  #   then
  #     sshd_config_set "$config_entry" "$value"
  #   fi
  # done
}

get_user_home() {
  local user="$1"
  if [ -z "$user" ]
  then
    echo "Usage: $0 USER" >&2
    return 2
  fi
  getent passwd "$user" | cut -f6 -d:
}

update_authorized_keys() {
  local auth_keys
  local home
  local ssh_dir

  home="$(get_user_home "${USER_NAME}")"
  ssh_dir="${home}/.ssh"
  auth_keys="${ssh_dir}/authorized_keys"

  mkdir -p "$ssh_dir"

  if [ -n "$AUTHORIZED_KEYS" ]
  then
    echo "Adding authorized_keys" >&2
    # shellcheck disable=2169
    echo -e "${AUTHORIZED_KEYS}" > "$auth_keys"
  fi

  if [ "$GITHUB_USERNAME" ]
  then
    echo "Fetching authorized_keys from GitHub for ${GITHUB_USERNAME}" >&2
    local keys
    keys="$(curl -fsSL "https://github.com/${GITHUB_USERNAME}.keys")"
    if echo "$keys" | grep -qE "^ssh-"
    then
      echo "$keys" >> "$auth_keys"
    else
      echo "Received invalid keys from GitHub: $keys" >&2
    fi
  fi

  chown -R "$USER_NAME" "$ssh_dir"
  chmod 600 "$auth_keys" 2>/dev/null
}

update_user() {
  local user="${1:-root}"
  local password="${2:-$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 120 | head -n 1)}"

  if [ "$user" != "root" ]
  then
    echo "Creating user $user" >&2
    adduser -D "$user"
  fi

  echo "Updating user password for $user" >&2
  echo "${user}:${password}" | chpasswd >/dev/null
}

update_sshd_config
update_user "$USER_NAME" "$PASSWORD"
update_authorized_keys

/usr/sbin/sshd -D -e -p "$SSHD_PORT"
