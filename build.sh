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
repo init -u https://github.com/LenaTDDS/kernel_manifest-raviole.git -b FreakyKernel-test
repo sync -j$(nproc --all)

msg " • 🌸 Patching KernelSU 🌸 "
cd $WORKDIR/private/gs-google
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
KERNELSU_VERSION=$(($KSU_GIT_VERSION + 10000 + 200))
msg " • 🌸 KernelSU version: $KERNELSU_VERSION 🌸 "

msg " • 🌸 Started Compilation 🌸 "
cd $WORKDIR
export LTO=full
export BUILD_AOSP_KERNEL=1 
./build_slider.sh

msg " • 🌸 Packing Kernel 🌸 "
cd out/mixed/dist
time=$(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S")
ZIP_NAME="ravioleKernel-KernelSU-$KERNELSU_VERSION.zip"
zip $ZIP_NAME boot.img dtbo.img vendor_boot.img vendor_dlkm.img
mkdir -p $WORKDIR/out && cp *.zip $WORKDIR/out

cd $WORKDIR/out
echo "FreakyKernel-KSU" > RELEASETITLE.txt
echo "
### FreakyKernel KERNEL With KERNELSU
1. **Time** : $(TZ='Europe/Moscow' date +"%Y-%m-%d %H:%M:%S") # Moscow TIME
2. **KERNELSU Version**: $KERNELSU_VERSION
" > RELEASE.md
cat RELEASE.md
cat RELEASETITLE.txt
msg "• 🌸 Done! 🌸 "
