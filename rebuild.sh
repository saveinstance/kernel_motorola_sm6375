#!/bin/bash
export PATH="$PWD/toolchain/bin:$PATH"
export KBUILD_BUILD_USER=saveinstance
export LLVM_DIR="$PWD/toolchain/bin"

export AnyKernel3=AnyKernel3
export modpath="$AnyKernel3/modules/vendor/lib/modules"

export TIME="$(date "+%Y%m%d")"

export ARCH=arm64
export SUBARCH=arm64
export LLVM=1

ARGS="CC=${LLVM_DIR}/clang LD=${LLVM_DIR}/ld.lld ARCH=arm64 AR=${LLVM_DIR}/llvm-ar NM=${LLVM_DIR}/llvm-nm AS=${LLVM_DIR}/llvm-as CROSS_COMPILE=${LLVM_DIR}/aarch64-linux-gnu CROSS_COMPILE_COMPAT=${LLVM_DIR}/arm-linux-gnueabi OBJCOPY=${LLVM_DIR}/llvm-objcopy OBJDUMP=${LLVM_DIR}/llvm-objdump READELF=${LLVM_DIR}/llvm-readelf OBJSIZE=${LLVM_DIR}/llvm-size STRIP=${LLVM_DIR}/llvm-strip LLVM_AR=${LLVM_DIR}/llvm-ar LLVM_DIS=${LLVM_DIR}/llvm-dis LLVM_NM=${LLVM_DIR}/llvm-nm LLVM=1 LLVM_IAS=1"

[ ! -e "out/arch/arm64/boot/Image" ] && \
    echo "  ERROR : image binary not found in any of the specified locations , fix compile!" && \
    exit 1

make O=out ${ARGS} -j$(nproc) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install
# Clean Up
rm -rf ${modpath}/*
rm -rf ${AnyKernel3}/{Image, dtb, dtbo.img}
rm -rf ${AnyKernel3}/*.zip

# Setup
mkdir -p ${modpath}
kver=$(make kernelversion)
kmod=$(echo ${kver} | awk -F'.' '{print $3}')

# Copy stuff
cp out/.config ${AnyKernel3}/config
cp out/arch/arm64/boot/Image ${AnyKernel3}/Image
cp out/arch/arm64/boot/dtb.img ${AnyKernel3}/dtb
cp out/arch/arm64/boot/dtbo.img ${AnyKernel3}/dtbo.img
cp $(find out/modules/lib/modules/5.4* -name '*.ko') ${modpath}/
cp out/modules/lib/modules/5.4*/modules.{alias,dep,softdep} ${modpath}/
cp out/modules/lib/modules/5.4*/modules.order ${modpath}/modules.load

# Edit
sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' ${modpath}/modules.dep
sed -i 's/.*\///; s/\.ko$//' ${modpath}/modules.load

# Zip
cd ${AnyKernel3}
zip -r9 O_KERNEL.${kmod}_${DEVICE}${KSUSTAT}-${TIME}.zip * -x .git README.md *placeholder