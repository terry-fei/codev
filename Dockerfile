FROM ubuntu:trusty
MAINTAINER feit "i@feit.me"

# dependency
RUN apt-get update && \
    apt-get install -y curl zsh tmux openssh-server git build-essential

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - && \
    apt-get install -y nodejs

# config sshd
RUN mkdir /var/run/sshd && \
    echo 'root:root' |chpasswd && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# install and config oh-my-zsh
RUN git clone git://github.com/bwithem/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    chsh -s /bin/zsh && \
    sed -i -E "s/^plugins=\((.*)\)$/plugins=(\1 tmux)/" ~/.zshrc

# change timezone
RUN echo "Asia/Shanghai" > /etc/timezone; 

EXPOSE 22 80

WORKDIR /codes
CMD ["/usr/sbin/sshd", "-D"]
