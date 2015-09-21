FROM ubuntu
MAINTAINER feit "i@feit.me"

RUN apt-get update -qq && \
    apt-get install -qqy openssh-server supervisor

RUN apt-get install -qqy --no-install-recommends samba \
    $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}')

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# not allow root login
RUN mkdir /var/run/sshd && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# samba global config
RUN useradd smbuser -M && \
    sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf && \
    sed -i '/Share Definitions/,$d' /etc/samba/smb.conf && \
    echo '   security = user' >> /etc/samba/smb.conf && \
    echo '   directory mask = 0775' >> /etc/samba/smb.conf && \
    echo '   force create mode = 0664' >> /etc/samba/smb.conf && \
    echo '   force directory mode = 0775' >> /etc/samba/smb.conf && \
    echo '   force user = smbuser' >> /etc/samba/smb.conf && \
    echo '   force group = users' >> /etc/samba/smb.conf && \
    echo '' >> /etc/samba/smb.conf

COPY boot.sh /usr/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22 139 445

CMD ["boot.sh"]
