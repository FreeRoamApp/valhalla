#!/usr/bin/env bash
set -e

# get all the ppas we might need
add-apt-repository -y ppa:valhalla-core/valhalla
apt-get update -y

# get all the dependencies might need
apt-get install -y git cmake make libtool pkg-config g++ gcc jq lcov protobuf-compiler vim-common libboost-all-dev libboost-all-dev libcurl4-openssl-dev zlib1g-dev liblz4-dev libprime-server0.6.3-dev libprotobuf-dev prime-server0.6.3-bin
apt-get install -y libsqlite3-mod-spatialite # for xenial
apt-get install -y nodejs libgeos-dev libgeos++-dev liblua5.2-dev libspatialite-dev libsqlite3-dev lua5.2 wget
apt-get install -y autoconf automake libtool make gcc g++ lcov
apt-get install -y libcurl4-openssl-dev libzmq3-dev libczmq-dev curl
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs python-all-dev
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

if [[ $(grep -cF xenial /etc/lsb-release) > 0 ]]; then
  apt-get install -y libsqlite3-mod-spatialite
fi

git clone https://github.com/kevinkreiser/prime_server.git libprimeserver
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
git clone https://github.com/valhalla/valhalla.git libvalhalla

cd libvalhalla
git submodule sync
git submodule update --init --recursive
npm install --ignore-scripts
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
cd ../../

# clean up
rm -rf libvalhalla
