#!/usr/bin/env bash
usage() {
  echo ""
}

createuser() { local name="${1}" passwd="${2}" \
                     project="${3}" file=/etc/samba/smb.conf
  useradd "$name" -m -s /bin/bash
  echo "$name ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "$name:$passwd" | chpasswd
  echo "$passwd" | tee - | smbpasswd -s -a "$name"
  sed -i "/\\[$project\\]/,/^\$/d" $file
  echo "[$project]" >> $file
  local path="/home/$name/$project"
  mkdir -p "$path"
  echo "   path = $path" >> $file
  echo "   browseable = yes" >> $file
  echo "   read only = no" >> $file
  echo "   guest ok = no" >> $file
  echo "   valid users = $name" >> $file
  echo "   admin users = $name" >> $file
  echo -e "" >> $file 
}

cd /tmp
while getopts "u:" opt; do
    case "$opt" in
        h) usage ;;
        u) eval createuser $(sed 's/:/ /g' <<< $OPTARG) ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done

exec supervisord
