#!/usr/bin/env bash
usage() { local RC=${1:-0}
  echo "should run with -e USERNAME=username -e PASSWORD=password -e PROJECT_NAME=project"
  exit $RC
}

createuser() { local name="${1}" passwd="${2}" \
                     project="${3}" file=/etc/samba/smb.conf
  # add system user
  useradd "$name" -m -s /bin/bash
  echo "$name ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "$name:$passwd" | chpasswd

  # change samba password
  echo "$passwd" | tee - | smbpasswd -s -a "$name"

  # samba global config
  sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf
  sed -i '/Share Definitions/,$d' /etc/samba/smb.conf
  echo "   security = user" >> $file
  echo "   directory mask = 0775" >> $file
  echo "   force create mode = 0664" >> $file
  echo "   force directory mode = 0775" >> $file
  echo "   force user = $name" >> $file
  echo "   force group = $name" >> $file
  echo "" >> $file

  # share folder config
  echo "[$project]" >> $file
  local path="/home/$name/$project"
  mkdir -p "$path" && chown "$name:$name" "$path"
  echo "   path = $path" >> $file
  echo "   browseable = yes" >> $file
  echo "   read only = no" >> $file
  echo "   writable = yes" >> $file
  echo "   guest ok = no" >> $file
  echo "   valid users = $name" >> $file
  echo -e "" >> $file
}

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ] && [ -n "$PROJECT_NAME" ]
then
  if id "$USERNAME" &>/dev/null
  then
    echo "user already create"
  else
    createuser $USERNAME $PASSWORD $PROJECT_NAME
  fi
else
  usage 2
fi

exec supervisord
