#!/bin/bash
#
# Compile script for kernel
#

SECONDS=0 # builtin bash timer

# Speed up build proces
MAKE="./makeparallel"

export PATH="$PWD/toolchain/bin/:$PATH"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyuxS
export KBUILD_BUILD_HOST=Github~Action
export KBUILD_COMPILER_STRING="$PWD/toolchain"

echo -e "\nStarting compilation for sweet...\n"
# Prompt user to choose the build type (MIUI or AOSP)
echo "Choose the build type:"
echo "1. MIUI"
echo "2. AOSP"
read -p "Enter the number of your choice: " build_choice

# Modify dtsi file if MIUI build is selected
if [ "$build_choice" = "1" ]; then
    sed -i 's/qcom,mdss-pan-physical-width-dimension = <69>;$/qcom,mdss-pan-physical-width-dimension = <695>;/' arch/arm64/boot/dts/qcom/dsi-panel-k6-38-0c-0a-fhd-dsc-video.dtsi
    sed -i 's/qcom,mdss-pan-physical-height-dimension = <154>;$/qcom,mdss-pan-physical-height-dimension = <1546>;/' arch/arm64/boot/dts/qcom/dsi-panel-k6-38-0c-0a-fhd-dsc-video.dtsi
    echo "MIUI build selected"
    zip_name="MIUI"
elif [ "$build_choice" = "2" ]; then
    echo "AOSP build selected"
    zip_name="AOSP"
else
    echo "Invalid choice. Exiting..."
    exit 1
fi
make O=out ARCH=arm64 vendor/sweet_defconfig
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
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

if [ -d "$AK3_DIR" ]; then
	cp -r $AK3_DIR AnyKernel3
else
	if ! git clone -q https://github.com/basamaryan/AnyKernel3 -b master AnyKernel3; then
		echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
		exit 1
	fi
fi

# Modify anykernel.sh to replace device names
sed -i "s/kernel\.string=.*/kernel.string=Kernel By @ZyuxS/" AnyKernel3/anykernel.sh
sed -i "s/device\.name1=.*/device.name1=sweet/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=sweetin/" AnyKernel3/anykernel.sh
sed -i "s/supported\.versions=.*/supported.versions=11-15/" AnyKernel3/anykernel.sh

cp $kernel AnyKernel3
cp $dtbo AnyKernel3
cp $dtb AnyKernel3
cd AnyKernel3
zip -r9 "../sweet-${zip_name}-$(date '+%Y%m%d-%H%M').zip" * -x .git
cd ..
rm -rf AnyKernel3

# Function to revert changes made to the dtsi file
revert_changes() {
    sed -i 's/qcom,mdss-pan-physical-width-dimension = <695>;$/qcom,mdss-pan-physical-width-dimension = <69>;/' arch/arm64/boot/dts/qcom/dsi-panel-k6-38-0c-0a-fhd-dsc-video.dtsi
    sed -i 's/qcom,mdss-pan-physical-height-dimension = <1546>;$/qcom,mdss-pan-physical-height-dimension = <154>;/' arch/arm64/boot/dts/qcom/dsi-panel-k6-38-0c-0a-fhd-dsc-video.dtsi
    }
    
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"

# Revert changes after compiling kernel
revert_changes

