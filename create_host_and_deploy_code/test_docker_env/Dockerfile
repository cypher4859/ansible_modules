FROM ubuntu:latest

RUN mkdir -p /root/.ssh/

COPY authorized_keys /root/.ssh/authorized_keys

RUN apt-get update && apt-get install -y openssh-client openssh-server vim
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && service ssh restart

CMD [ "/bin/bash" ]