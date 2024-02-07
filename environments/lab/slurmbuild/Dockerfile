FROM rockylinux:8 as build-stage

ARG SLURM_VERSION=23.11.0 # From https://www.schedmd.com/downloads.php
ARG SLURM_PREFIX=/opt/slurm # Should match directory Slurm is installed at
ARG SLURM_SYSCONFDIR=/etc/slurm # Should match directory slurm.conf will be in

RUN set -ex \
    && yum makecache \
    && yum -y update \
    && yum -y install dnf-plugins-core epel-release \
    && yum -y install dnf-plugins-core \
    && yum config-manager --set-enabled powertools \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-devel \
       python3-devel \
       python3-pip \
       python3 \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
       http-parser-devel \
       json-c-devel \
       mpitests-openmpi \
       pmix-devel \
       hwloc \
       hwloc-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN alternatives --set python /usr/bin/python3

RUN pip3 install Cython nose

RUN set -x \
    && wget https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 \
    && tar --bzip -x -f slurm*tar.bz2

WORKDIR /slurm-${SLURM_VERSION}

RUN set -x && ./configure \
        --enable-debug \
        --prefix=${SLURM_PREFIX} \
        --without-rpath \
        --sysconfdir=${SLURM_SYSCONFDIR} \
        --with-mysql_config=/usr/bin

RUN set -x && make install

ENTRYPOINT ["/bin/bash"]


FROM scratch as export-stage

ARG SLURM_PREFIX=/slurm # Should match directory Slurm is installed at
# RUN ls ${SLURM_PREFIX}
COPY --from=build-stage ${SLURM_PREFIX}/ .
