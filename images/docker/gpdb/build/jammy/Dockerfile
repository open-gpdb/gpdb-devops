# --------------------------------------------------------------------
# Dockerfile for Greenplum Build Environment
# --------------------------------------------------------------------

FROM ubuntu:jammy

ARG accessKeyId
ARG secretAccessKey
ARG bucketName
ARG yezzeyRef

ENV YEZZEY_REF=${yezzeyRef:-v1.8_opengpdb}

# Argument for configuring the timezone
ARG TIMEZONE_VAR="Europe/London"


SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN stat -fc %T /sys/fs/cgroup/

RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && echo $TIMEZONE_VAR > /etc/timezone

# --------------------------------------------------------------------
# Install Development Tools and Utilities
# --------------------------------------------------------------------
RUN apt-get update -o Acquire::AllowInsecureRepositories=true && apt-get install -y --no-install-recommends --allow-unauthenticated \
  build-essential \
  libssl-dev \
  gnupg \
  devscripts \
  openssl \
  libssl-dev \
  debhelper \
  debootstrap \
  libfakeroot \
  make \
  equivs \
  bison \
  ca-certificates-java \
  ca-certificates \
  cmake \
  curl \
  cgroup-tools \
  flex \
  gcc-11 \
  g++-11 \
  g++-11-multilib \
  git \
  iputils-ping \
  krb5-multidev \
  libapr1-dev \
  libbz2-dev \
  libcurl4-gnutls-dev \
  libpstreams-dev \
  libevent-dev \
  libkrb5-dev \
  libldap2-dev \
  libperl-dev \
  libreadline-dev \
  libssl-dev \
  libxml2-dev \
  libyaml-dev \
  libzstd-dev \
  libaprutil1-dev \
  libpam0g-dev \
  libpam0g \
  libpopt0 \
  libcgroup1 \
  libyaml-0-2 \
  libldap-2.5-0 \
  libssl3 \
  net-tools \
  ninja-build \
  python-setuptools \
  quilt \
  unzip \
  wget \
  zlib1g-dev \
  libuv1-dev \
  libgpgme-dev \
  libgpgme11 \
  python2.7 \
  python2.7-dev \
  python-pip \
  python-six \
  rsync \
  sudo \
  tzdata \
  iproute2 \
  less \
  software-properties-common \
  openssh-client \
  openssh-server \
  locales \
  postgresql-client


RUN pip2 install psutil pyyaml

RUN apt-get install -y locales \
&& locale-gen "en_US.UTF-8" \
&& update-locale LC_ALL="en_US.UTF-8"

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

RUN echo ${TIMEZONE_VAR} > /etc/timezone && \
    chmod 777 /tmp/init_system.sh && \
    groupadd gpadmin && \
    useradd -rm -d /home/gpadmin -s /bin/bash -g root -G sudo -u 1001 gpadmin && \
    echo 'gpadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers && \
    locale-gen "en_US.UTF-8" && \
    update-locale LC_ALL="en_US.UTF-8"

USER gpadmin
ENV USER=gpadmin
WORKDIR /home/gpadmin

RUN sudo DEBIAN_FRONTEND=noninteractive apt install -y libhyperic-sigar-java libaprutil1-dev libuv1-dev

# --------------------------------------------------------------------
# Set the Default User and Command
# --------------------------------------------------------------------
# The default user is set to 'gpadmin', and the container starts by
# running the init_system.sh script. This container serves as a base
# environment, and the Greenplum Database DEB package can be installed
# for testing and functional verification.
# --------------------------------------------------------------------
USER gpadmin

CMD ["bash","-c","/tmp/init_system.sh"]