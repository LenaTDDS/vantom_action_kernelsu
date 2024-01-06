#!/bin/bash
msg() {
	echo
	echo -e "\e[1;32m$*\e[0m"
	echo
}

WORKDIR="$(pwd)"

msg " • 🌸 Cloning Kernel Source 🌸 "
mkdir -p raviole-kernel && cd raviole-kernel
# repo init -u https://github.com/opensourcefreak/FreakyKernel-raviole -b Tiramisu-5.10
mv manifest.xml .repo/manifest.xml
repo init -m manifest.xml
repo sync -j$(nproc --all)

msg " • 🌸 Patching KernelSU 🌸 "
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
KERNELSU_VERSION=$(($KSU_GIT_VERSION + 10000 + 200))
msg " • 🌸 KernelSU version: $KERNELSU_VERSION 🌸 "

msg " • 🌸 Started Compilation 🌸 "
export LTO=full
export BUILD_AOSP_KERNEL=1
bash ./build_slider.sh

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