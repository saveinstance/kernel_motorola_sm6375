#!/bin/bash
[ ! -e " KernelSU-Next/kernel/setup.sh" ] && git submodule init && git submodule update
[ ! -d "toolchain" ] && echo  "installing toolchain..." && bash init_clang.sh

export PATH="$PWD/toolchain/bin:$PATH"
export LLVM_DIR="$PWD/toolchain/bin"

export TIME="$(date "+%Y%m%d")"

export ARCH=arm64
export SUBARCH=arm64
export LLVM=1

ARGS="CC=${LLVM_DIR}/clang LD=${LLVM_DIR}/ld.lld ARCH=arm64 AR=${LLVM_DIR}/llvm-ar NM=${LLVM_DIR}/llvm-nm AS=${LLVM_DIR}/llvm-as CROSS_COMPILE=${LLVM_DIR}/aarch64-linux-gnu CROSS_COMPILE_COMPAT=${LLVM_DIR}/arm-linux-gnueabi OBJCOPY=${LLVM_DIR}/llvm-objcopy OBJDUMP=${LLVM_DIR}/llvm-objdump READELF=${LLVM_DIR}/llvm-readelf OBJSIZE=${LLVM_DIR}/llvm-size STRIP=${LLVM_DIR}/llvm-strip LLVM_AR=${LLVM_DIR}/llvm-ar LLVM_DIS=${LLVM_DIR}/llvm-dis LLVM_NM=${LLVM_DIR}/llvm-nm LLVM=1 LLVM_IAS=1"

# Clean
# make mrproper

# Build
make ${ARGS} O=out vendor/bangkk_defconfig
make ${ARGS} O=out -j$(nproc)

[ ! -e "out/arch/arm64/boot/Image" ] && \
    echo "  ERROR : image binary not found in any of the specified locations , fix compile!" && \
    exit 1