FROM rockylinux/rockylinux
ENV container=docker

ENV pip_packages "ansible selinux"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-*.repo

# Install requirements.
RUN dnf makecache  \
 && dnf -y install rpm epel-release initscripts \
 && dnf -y update \
 && dnf -y install \
      crontabs \
      vim \
      wget \
      sudo \
      which \
      hostname \
      python3 \
      python3-pip \
      unzip \
      'dnf-command(config-manager)' \
      git

RUN echo "fastestmirror=True" >> /etc/dnf/dnf.conf

COPY pip /root/.pip

RUN pip3 install -U pip  -i https://mirrors.aliyun.com/pypi/simple/


# Install Ansible via Pip.
RUN pip3 install $pip_packages -i https://mirrors.aliyun.com/pypi/simple/

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
