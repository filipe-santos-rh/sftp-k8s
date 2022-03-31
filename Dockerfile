FROM registry.access.redhat.com/ubi8/ubi:latest

# update all packages
RUN yum -y upgrade

# install needed packages
RUN yum install -y openssh-server python3

# add pam configs
COPY --chown=root:root pam_sshd /etc/pam.d/sshd

# add authorized keys script
COPY list-authorized-keys /etc/ssh/

# add sleepysh shell
COPY sleepysh /bin/

# add sre-user
RUN useradd sre-user && \
    sed -i '/sre-user/d' /etc/passwd
RUN rm -rf /home/sre-user

# needed for openshift
RUN chgrp -R 0 /opt && \
    chmod g+w /etc/passwd && \
    chmod  g+rwX /home && \
    chmod  g+rwX /opt

# copy startup script
COPY start-sshd.sh /opt/

USER 1000
WORKDIR  /opt
CMD ["/opt/start-sshd.sh"]
