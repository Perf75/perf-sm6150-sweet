#!/bin/bash
#
# Setup kernelSU & Ubuntu
#

# Setup drivers kernelSU 
git clone https://github.com/backslashxx/KernelSU.git -b magic-152

# Setup kernelSU 
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/magic-152/kernel/setup.sh" | bash -s main

# Install Dependency 
sudo apt update && sudo apt upgrade -y && sudo apt install dialog rlwrap apt-utils -y && sudo apt install nano bc bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd sudo make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu -y && sudo apt install build-essential -y && sudo apt install libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev make gcc -y && sudo apt install pigz -y && sudo apt install python2 -y && sudo apt install python3 -y && sudo apt install cpio -y && sudo apt install lld -y && sudo apt install llvm -y && sudo apt-get install g++-aarch64-linux-gnu -y && sudo apt install libelf-dev -y && sudo apt install neofetch -y && neofetch

# Update Ubuntu 
sudo apt install ubuntu-release-upgrader-core && sudo apt install update-manager-core && sudo apt-get update -y && sudo do-release-upgrade && sudo apt install neofetch -y && neofetch

# Download Neutron Clang 19
mkdir toolchain && cd toolchain && curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman" && chmod a+x antman && ./antman -S && ./antman --patch=glibc && cd .. && ls && realpath neutron-clang

