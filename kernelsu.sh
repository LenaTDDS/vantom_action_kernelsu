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
# git clone --depth=1 $KERNEL_GIT -b $KERNEL_BRANCHE $KERNEL_DIR
cd $KERNEL_DIR

msg " • 🌸 Patching KernelSU 🌸 "
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
KERNELSU_VERSION=$(($KSU_GIT_VERSION + 10000 + 200))
msg " • 🌸 KernelSU version: $KERNELSU_VERSION 🌸 "

# BUILD KERNEL
msg " • 🌸 Started Compilation 🌸 "
export LTO=full 
export BUILD_AOSP_KERNEL=1 
./build_slider.sh

msg " • 🌸 Packing Kernel 🌸 "
cd $WORKDIR
git clone --depth=1 $ANYKERNEL3_GIT -b $ANYKERNEL3_BRANCHE $WORKDIR/Anykernel3
cd $WORKDIR/Anykernel3
cp $IMAGE .

# PACK FILE
time=$(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S")
cairo_time=$(TZ='Europe/Moscow' date +%Y%m%d%H)
ZIP_NAME="GrapheneOS-Kernel-KSU-$KERNELSU_VERSION.zip"
find ./ * -exec touch -m -d "$time" {} \;
zip -r9 $ZIP_NAME *
mkdir -p $WORKDIR/out && cp *.zip $WORKDIR/out

cd $WORKDIR/out
echo "
### GrapheneOS KERNEL With KERNELSU
1. **Time** : $(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S") # Moscow TIME
2. **KERNELSU Version**: $KERNELSU_VERSION
3. **CLANG Version**: $CLANG_VERSION
4. **LLD Version**: $LLD_VERSION
" > RELEASE.md
echo "
echo "GrapheneOS-Kernel-KSU" > RELEASETITLE.txt
cat RELEASE.md
cat RELEASETITLE.txt
msg "• 🌸 Done! 🌸 "
