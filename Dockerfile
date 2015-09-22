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
    sed -ri 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY boot.sh /usr/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22 139 445

ENTRYPOINT ["boot.sh"]
