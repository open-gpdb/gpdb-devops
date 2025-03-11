#!/bin/bash
#
# Script Name: build-deb.sh
#
# Description:
# This script automates the process of building an DEBIAN package using a specified
# version and release number.


git clone https://github.com/boundary/sigar.git -b master \
&& wget -c https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.1.1.tar.gz -O - | tar -xz

mv gpdb-devops/packaging/deb/jammy/debian ./

sudo apt-get update && sudo apt-get install -y python devscripts debhelper dupload git pbuilder ca-certificates debsigs reprepro


cat > changelog.sh <<EOF1
cat <<EOF
greenplum-db-6 (\${GPDB_PKG_VERSION}) stable; urgency=low

  * open-gpdb autobuild
-- Vladimir Rachkin <robozmey@$(hostname)>  $(date +'%a, %d %b %Y %H:%M:%S %z')
EOF
EOF1
chmod +x changelog.sh

export BUILD_USER="Vladimir Rachkin"
export GPDB_VERSION=$(./getversion | cut -d'.' -f 1)
export GPDB_FULL_VERSION=$(./getversion | cut -d'-' -f 1 | cut -d'+' -f 1)
export GPDB_PKG_VERSION=${GPDB_FULL_VERSION}-${BUILD_NUMBER}-yandex.$(git rev-list HEAD --count).$(git rev-parse --short HEAD)
echo "##teamcity[buildNumber '%build.counter%: ${GPDB_PKG_VERSION}']"

./changelog.sh > debian/changelog
cat debian/changelog
mk-build-deps  --build-dep --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' debian/control
dpkg-buildpackage -us -uc

all_debs=$(ls *deb)
