#!/bin/bash
msg() {
	echo
	echo -e "\e[1;32m$*\e[0m"
	echo
}

WORKDIR="$(pwd)"
# Kernel Source
KERNEL_GIT="https://github.com/opensourcefreak/FreakyKernel-raviole.git"
KERNEL_BRANCH="Tiramisu-5.10"
KERNEL_DIR="$WORKDIR/raviole-kernel"

msg " • 🌸 Cloning Kernel Source 🌸 "
export KBUILD_BUILD_USER=LenaTDDS
export KBUILD_BUILD_HOST=GitHubCI

mkdir -p raviole-kernel && cd raviole-kernel
#repo init -u https://github.com/LenaTDDS/kernel_manifest-raviole.git -b FreakyKernel
#repo sync -j$(nproc --all)
git clone --depth=1 $KERNEL_GIT -b $KERNEL_BRANCH $KERNEL_DIR

msg " • 🌸 Patching KernelSU 🌸 "
cd $KERNEL_DIR
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
KERNELSU_VERSION=$(($KSU_GIT_VERSION + 10000 + 200))
msg " • 🌸 KernelSU version: $KERNELSU_VERSION 🌸 "

msg " • 🌸 Started Compilation 🌸 "
export LTO=full
export BUILD_CONFIG=build.config.slider
./build_mixed.sh

msg " • 🌸 Packing Kernel 🌸 "
cd out/mixed/dist
time=$(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S")
ZIP_NAME="ravioleKernel-KernelSU-$KERNELSU_VERSION.zip"
zip $ZIP_NAME boot.img dtbo.img vendor_boot.img vendor_dlkm.img
mkdir -p $WORKDIR/out && cp *.zip $WORKDIR/out
cd $WORKDIR/out
echo "
### raviole kernel with KernelSU
1. **Time** : $(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S") # Moscow TIME
2. **KERNELSU Version**: $KERNELSU_VERSION
" > RELEASE.md
echo "
echo "ravioleKernel-$KERNEL_VERSION" > RELEASETITLE.txt
cat RELEASE.md
cat RELEASETITLE.txt
msg "• 🌸 Done! 🌸 "