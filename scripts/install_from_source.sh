#!/usr/bin/env bash
set -e

# get all the ppas we might need
add-apt-repository -y ppa:valhalla-core/valhalla
apt-get update -y

# get all the dependencies might need
apt-get install -y cmake make libtool pkg-config g++ gcc jq lcov protobuf-compiler vim-common libboost-all-dev libboost-all-dev libcurl4-openssl-dev zlib1g-dev liblz4-dev libprime-server0.6.3-dev libprotobuf-dev prime-server0.6.3-bin nodejs

if [[ $(grep -cF xenial /etc/lsb-release) > 0 ]]; then
  apt-get install -y libsqlite3-mod-spatialite
fi

git clone \
  --depth=1 \
  --recurse-submodules \
  --single-branch \
  --branch=master \
  https://github.com/kevinkreiser/prime_server.git libprimeserver
cd libprimeserver
git submodule update --init --recursive
./autogen.sh
./configure
make test -j8
make install
cd -

# clean up
rm -rf libprimeserver

# get the software installed
git clone \
  --depth=1 \
  --recurse-submodules \
  --single-branch \
  --branch=master \
  https://github.com/valhalla/valhalla.git libvalhalla

cd libvalhalla
git submodule update --init --recursive
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
cd -

# clean up
rm -rf libvalhalla
