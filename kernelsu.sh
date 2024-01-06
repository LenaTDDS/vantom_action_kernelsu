#!/usr/bin/env sh
#
# GNU General Public License v3.0
# Copyright (C) 2023 MoChenYa mochenya20070702@gmail.com
#

WORKDIR="$(pwd)"

# Kernel Source
KERNEL_GIT="https://github.com/opensourcefreak/FreakyKernel-raviole"
KERNEL_BRANCH="Tiramisu-5.10"
KERNEL_DIR="$WORKDIR/FreakyKernel-raviole"

# Anykernel3
ANYKERNEL3_GIT="https://github.com/osm0sis/AnyKernel3.git"
ANYKERNEL3_BRANCHE="master"


OUT_KERNEL_LZ4="$WORKDIR/out/mixed/dist/Image.lz4"
OUT_KERNEL_RAW="$WORKDIR/out/mixed/dist/boot.img"

export KBUILD_BUILD_USER=LenaTDDS
export KBUILD_BUILD_HOST=GitHubCI

msg() {
	echo
	echo -e "\e[1;32m$*\e[0m"
	echo
}

cd $WORKDIR

msg " • 🌸 Cloning Kernel Source 🌸 "
git config --global color.ui false
git clone --depth=1 $KERNEL_GIT -b $KERNEL_BRANCHE
cd $KERNEL_DIR

msg " • 🌸 Patching KernelSU 🌸 "
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
KERNELSU_VERSION=$(($KSU_GIT_VERSION + 10000 + 200))
msg " • 🌸 KernelSU version: $KERNELSU_VERSION 🌸 "

# BUILD KERNEL
msg " • 🌸 Started Compilation 🌸 "
cd $WORKDIR
export BUILD_AOSP_KERNEL=1 
./build_slider.sh

msg " • 🌸 Packing Kernel 🌸 "
git clone --depth=1 $ANYKERNEL3_GIT -b $ANYKERNEL3_BRANCHE $WORKDIR/Anykernel3
cd $WORKDIR/Anykernel3
cp $OUT_KERNEL_LZ4 $OUT_KERNEL_RAW .

# PACK FILE
time=$(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S")
ZIP_NAME="GrapheneOS-Kernel-KSU-$KERNELSU_VERSION.zip"
find ./ * -exec touch -m -d "$time" {} \;
zip -r9 $ZIP_NAME *
mkdir -p $WORKDIR/out && cp *.zip $WORKDIR/out

cd $WORKDIR/out
echo "GrapheneOS-Kernel-KSU" > RELEASETITLE.txt
echo "
### GrapheneOS KERNEL With KERNELSU
1. **Time** : $(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S") # Moscow TIME
2. **KERNELSU Version**: $KERNELSU_VERSION
3. **CLANG Version**: $CLANG_VERSION
4. **LLD Version**: $LLD_VERSION
" > RELEASE.md
cat RELEASE.md
cat RELEASETITLE.txt
msg "• 🌸 Done! 🌸 "
