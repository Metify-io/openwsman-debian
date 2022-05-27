#!/bin/bash -eux

# This file invokes the container and builds the packages

go() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get -y --no-install-recommends -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade
  apt-get -y --no-install-recommends -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install build-essential ca-certificates devscripts equivs pkg-config wget
  mkdir -p /src
  cd /src
  wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/o/openwsman/openwsman_2.6.5-0ubuntu6.dsc \
       https://mirrors.edge.kernel.org/ubuntu/pool/universe/o/openwsman/openwsman_2.6.5.orig.tar.gz \
       https://mirrors.edge.kernel.org/ubuntu/pool/universe/o/openwsman/openwsman_2.6.5-0ubuntu6.debian.tar.xz \
       https://mirrors.edge.kernel.org/ubuntu/pool/universe/s/sblim-sfcc/sblim-sfcc_2.2.8-0ubuntu2.dsc \
       https://mirrors.edge.kernel.org/ubuntu/pool/universe/s/sblim-sfcc/sblim-sfcc_2.2.8.orig.tar.bz2 \
       https://mirrors.edge.kernel.org/ubuntu/pool/universe/s/sblim-sfcc/sblim-sfcc_2.2.8-0ubuntu2.debian.tar.xz

  # Building libcimcclient0-dev, which is a build dep of openwsman
  dpkg-source -x sblim-sfcc_2.2.8-0ubuntu2.dsc
  cd sblim-sfcc-2.2.8
  # Add the -y to the command so it's noninteractive
  mk-build-deps -i -t '/usr/bin/apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y'
  # debuild fails with message about trying to modify the build-deps files otherwise
  rm *build-deps_*
  debuild -us -uc

  cd ..

  dpkg -i --no-debsig libcimcclient0-dev_2.2.8-0ubuntu2_amd64.deb libcimcclient0_2.2.8-0ubuntu2_amd64.deb libcimcclient0-dbgsym_2.2.8-0ubuntu2_amd64.deb

  # Building openwsman
  dpkg-source -x openwsman_2.6.5-0ubuntu6.dsc
  cd openwsman-2.6.5

  # Apply our changes to build for Python 3
  patch -p1 < /script/python3.patch
  EDITOR=/bin/true dpkg-source --commit . build_on_python3

  mk-build-deps -i -t '/usr/bin/apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y'
  rm *build-deps_*
  debuild -us -uc

  cd ..

  # Now, create the repo
  cp -v *.deb /artifacts/
  cd /artifacts
  dpkg-scanpackages -m . > Packages
  cat Packages | gzip -9c > Packages.gz
}


if [[ "${1:-}" == "--go" ]]; then
  go
else
  docker run --rm -v $(pwd):/script -v $(pwd)/artifacts:/artifacts debian:11.3-slim /script/do_build.sh --go
fi
