#!/usr/bin/env sh
#
# GNU General Public License v3.0
# Copyright (C) 2023 MoChenYa mochenya20070702@gmail.com
#

WORKDIR="$(pwd)"

# ZyClang
ZYCLANG_DLINK="https://github.com/ZyCromerZ/Clang/releases/download/18.0.0-20231017-release/Clang-18.0.0-20231017.tar.gz"
ZYCLANG_DIR="$WORKDIR/ZyClang/bin"

# Kernel Source
KERNEL_GIT="https://github.com/GrapheneOS/kernel_manifest-raviole"
KERNEL_BRANCHE="14"
KERNEL_DIR="$WORKDIR/GrapheneOSKernel"

# Anykernel3
ANYKERNEL3_GIT="https://github.com/osm0sis/AnyKernel3.git"
ANYKERNEL3_BRANCHE="master"

# Build
KERNEL_GS="https://github.com/GrapheneOS/kernel_build-gs"
KERNEL_GS_BRANCH="14"
IMAGE="$KERNEL_DIR/out/mixed/dist/boot.img"

export KBUILD_BUILD_USER=LenaTDDS
export KBUILD_BUILD_HOST=GitHubCI

msg() {
	echo
	echo -e "\e[1;32m$*\e[0m"
	echo
}

cd $WORKDIR

# Download ZyClang
msg " • 🌸 Work on $WORKDIR 🌸"
msg " • 🌸 Cloning Toolchain 🌸 "
mkdir -p ZyClang
aria2c -s16 -x16 -k1M $ZYCLANG_DLINK -o ZyClang.tar.gz
tar -C ZyClang/ -zxvf ZyClang.tar.gz
rm -rf ZyClang.tar.gz

# CLANG LLVM VERSIONS
CLANG_VERSION="$($ZYCLANG_DIR/clang --version | head -n 1)"
LLD_VERSION="$($ZYCLANG_DIR/ld.lld --version | head -n 1)"

msg " • 🌸 Cloning Kernel Source 🌸 "
repo init -u $KERNEL_GIT -b $KERNEL_BRANCHE $KERNEL_DIR
repo sync -j$(nproc --all)
git clone --depth=1 $KERNEL_GS -b $KERNEL_GS_BRANCH $KERNEL_DIR
# git clone --depth=1 $KERNEL_GIT -b $KERNEL_BRANCHE $KERNEL_DIR
cd $KERNEL_DIR
ls -la $KERNEL_DIR
ls -la

