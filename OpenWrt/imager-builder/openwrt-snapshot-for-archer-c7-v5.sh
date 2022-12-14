#!/bin/bash

## https://openwrt.org/docs/guide-user/additional-software/imagebuilder#prerequisites

if [[ $EUID -eq 0 ]]; then
  apt update
  apt install -y build-essential libncurses5-dev libncursesw5-dev \
  zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python3 python3-distutils
  update-alternatives --install /usr/bin/python python /usr/bin/python3 1
  exit
fi

mkdir --parents ~/.openwrt-snapshots
rm -rf ~/.openwrt-snapshots/archer-c7-v5

if [[ $(wget -q --spider https://downloads.openwrt.org/snapshots/targets/ath79/generic/openwrt-imagebuilder-ath79-generic.Linux-x86_64.tar.xz) -eq "0" ]]; then
    wget --https-only --inet4-only https://downloads.openwrt.org/snapshots/targets/ath79/generic/openwrt-imagebuilder-ath79-generic.Linux-x86_64.tar.xz
    if [ $? -nq 0 ]; then
      exit
    fi
    tar -J -x -f openwrt-imagebuilder-ath79-generic.Linux-x86_64.tar.xz
    rm -rf openwrt-imagebuilder-ath79-generic.Linux-x86_64.tar.xz
    cd openwrt-imagebuilder-ath79-generic.Linux-x86_64/
    source ../../packages.sh
    PROFILE_="tplink_archer-c7-v5"
    BIN_DIR_="~/.openwrt-snapshots/archer-c7-v5"
    rm -rf $BIN_DIR_
    make -j $(expr $(nproc) - 1) image PROFILE=$PROFILE_ PACKAGES="$PACKAGES_BASIC_" BIN_DIR=$BIN_DIR_ 
    make clean
    cd ..
    rm -rf openwrt-imagebuilder-ath79-generic.Linux-x86_64/
fi
