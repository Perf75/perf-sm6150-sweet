#!/bin/bash
#
# Compile script for kernel sweet
#

# Delet out folder 
rm -rf out/

if [ ! -d "KernelSU" ]; then
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/magic-152/kernel/setup.sh" | bash -s main
fi

# KERNEL ZIP
ZIPNAME="sweet-$(date '+%Y%m%d-%H%M').zip"

# DEFCONFIG
KERNEL_DEFCONFIG=vendor/sweet

# Speed up build proces
MAKE="./makeparallel"

# Building Kernel 
export PATH="$PWD/toolchain/bin/:$PATH"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyuxS
export KBUILD_BUILD_HOST=Not-Gaming-Kernel
export KBUILD_COMPILER_STRING="($PWD/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

make mrproper 

make O=out ARCH=arm64 $KERNEL_DEFCONFIG
make -j$(nproc --all) \ O=out \ ARCH=arm64 \ LLVM=1 \ LLVM_IAS=1 \ AR=llvm-ar \ NM=llvm-nm \ LD=ld.lld \ OBJCOPY=llvm-objcopy \ OBJDUMP=llvm-objdump \ STRIP=llvm-strip \ CC=clang \ CROSS_COMPILE=aarch64-linux-gnu- \ CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
	echo -e "\nCompilation failed!"
	exit 1
fi

echo -e "\nKernel compiled successfully! Zipping up...\n"

if [ ! -d "AnyKernel3" ]; then
git clone  --depth=1 https://github.com/Zeux775/AnyKernel3.git -b master AnyKernel3
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
rm -rf AnyKernel3/Image.gz
rm -rf AnyKernel3/dtbo.img
rm -rf AnyKernel3/dtb.img

echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"

