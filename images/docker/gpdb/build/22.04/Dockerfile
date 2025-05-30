# --------------------------------------------------------------------
# Dockerfile for Greenplum Build Environment
# --------------------------------------------------------------------

FROM ubuntu:22.04

ARG accessKeyId
ARG secretAccessKey
ARG bucketName
ARG yezzeyRef

ENV YEZZEY_REF=${yezzeyRef:-v1.8_opengpdb}
ENV DEBIAN_FRONTEND=noninteractive

# Argument for configuring the timezone
ARG TIMEZONE_VAR="Europe/London"

# --------------------------------------------------------------------
# Install Development Tools and Utilities
# --------------------------------------------------------------------
RUN sed -i "s/archive.ubuntu.com/mirror.yandex.ru/g" /etc/apt/sources.list && \
  apt-get update -o Acquire::AllowInsecureRepositories=true && apt-get install -y --no-install-recommends --allow-unauthenticated \
  bison \
  build-essential \
  ca-certificates \
  ca-certificates-java \
  cgroup-tools \
  cmake \
  curl \
  debhelper \
  debootstrap \
  devscripts \
  equivs \
  flex \
  g++-11 \
  g++-11-multilib \
  gcc-11 \
  git \
  gnupg \
  iproute2 \
  iputils-ping \
  krb5-multidev \
  less \
  libapr1-dev \
  libaprutil1-dev \
  libbz2-dev \
  libcgroup1 \
  libcurl4-gnutls-dev \
  libevent-dev \
  libfakeroot \
  libgpgme11 \
  libgpgme-dev \
  libhyperic-sigar-java \
  libkrb5-dev \
  libldap-2.5-0 \
  libldap2-dev \
  libpam0g \
  libpam0g-dev \
  libperl-dev \
  libpopt0 \
  libpstreams-dev \
  libreadline-dev \
  libssl3 \
  libssl-dev \
  libuv1-dev \
  libxml2-dev \
  libyaml-0-2 \
  libyaml-dev \
  libzstd-dev \
  locales \
  make \
  net-tools \
  ninja-build \
  openssh-client \
  openssh-server \
  openssl \
  postgresql-client \
  python2.7 \
  python2.7-dev \
  python-pip \
  python-setuptools \
  python-six \
  quilt \
  rsync \
  software-properties-common \
  sudo \
  tzdata \
  unzip \
  wget \
  zlib1g-dev

RUN pip2 install psutil pyyaml

RUN cd /tmp/ \
&& git clone https://github.com/greenplum-db/gp-xerces-archive.git \
&& cd ./gp-xerces-archive/ && mkdir build && cd build && ../configure --prefix=/usr/local && make -j \
&& sudo make install

RUN cd /tmp/ \
&& git clone https://github.com/boundary/sigar.git -b master \
&& cd ./sigar/ \
&& mkdir build && cd build && cmake .. && make \
&& sudo make install

# --------------------------------------------------------------------
# Copy Configuration Files and Setup the Environment
# --------------------------------------------------------------------

RUN ln -s /usr/bin/python2.7 /usr/bin/python

COPY ./configs/* /tmp/

RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo ${TIMEZONE_VAR} > /etc/timezone && \
    chmod 777 /tmp/init_system.sh && \
    chmod +x /tmp/init_system.sh && \
    groupadd gpadmin && \
    useradd -rm -d /home/gpadmin -s /bin/bash -g root -G sudo -u 1001 gpadmin && \
    echo 'gpadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-gpadmin && \
    chmod 0440 /etc/sudoers.d/90-gpadmin && \
    locale-gen "en_US.UTF-8" && \
    update-locale LC_ALL="en_US.UTF-8"

# --------------------------------------------------------------------
# Set the Default User and Command
# --------------------------------------------------------------------
# The default user is set to 'gpadmin', and the container starts by
# running the init_system.sh script. This container serves as a base
# environment, and the Greenplum Database DEB package can be installed
# for testing and functional verification.
# --------------------------------------------------------------------
USER gpadmin
ENV USER=gpadmin
WORKDIR /home/gpadmin

CMD ["bash","-c","/tmp/init_system.sh"]
