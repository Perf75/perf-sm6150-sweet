#!/bin/bash
#
# Compile script for kernel sweet
#

# mproper
make mrproper

# Delet out folder 
rm -rf out/

# Download AOSP Clang 19.0.1 r536225
mkdir toolchain && cd toolchain && wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r536225.tar.gz && tar -xzf clang-r536225.tar.gz && rm -rf clang-r536225.tar.gz && cd ..

# Git Clone KernelSU Drivers
git clone https://github.com/backslashxx/KernelSU.git -b magic-152

# Setup KernelSU Drivers 
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/magic-152/kernel/setup.sh" | bash -s main

# Speed up build proces
MAKE="./makeparallel"

# Building Kernel 
export PATH="$PWD/toolchain/bin/:$PATH"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyuxS
export KBUILD_BUILD_HOST=Github-Action
export KBUILD_COMPILER_STRING="$PWD/toolchain/bin"

make O=out ARCH=arm64 vendor/sweet_defconfig
make -j$(nproc --all) \ 
        O=out \ 
        ARCH=arm64 \ 
        LLVM=1 \ 
        LLVM_IAS=1 \ 
        AR=llvm-ar \ 
        NM=llvm-nm \ 
        LD=ld.lld \ 
        OBJCOPY=llvm-objcopy \ 
        OBJDUMP=llvm-objdump \ 
        STRIP=llvm-strip \ 
        CC=clang \ 
        CLANG_TRIPLE=aarch64-linux-gnu- \ 
        CROSS_COMPILE=aarch64-linux-gnu- \ 
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
	echo -e "\nCompilation failed!"
	exit 1
fi

echo -e "\nKernel compiled successfully! Zipping up...\n"

if [ ! -d "AnyKernel3" ]; then
git clone  --depth=1 https://github.com/Perf75/Anykernel3.git -b master AnyKernel3
fi

# Modify anykernel.sh to replace device names
sed -i "s/device\.name1=.*/device.name1=sweet/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=sweetin/" AnyKernel3/anykernel.sh
sed -i "s/supported\.versions=.*/supported.versions=11-15/" AnyKernel3/anykernel.sh

cp $kernel AnyKernel3
cp $dtbo AnyKernel3
cp $dtb AnyKernel3
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git
cd ..
rm -rf AnyKernel3

ZIPNAME="sweet-$(date '+%Y%m%d-%H%M').zip"

echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo " Zip: $ZIPNAME"

