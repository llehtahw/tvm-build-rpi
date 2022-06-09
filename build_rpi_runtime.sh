set -e
set -x
mkdir -p build.tvm.rpi build.spirv-tools.rpi install.rpi

# SPIRV-Tools
[ -e ./SPIRV-Tools/external/SPIRV-Headers ] || ln -s ../../SPIRV-Headers SPIRV-Tools/external/

cmake --toolchain $PWD/aarch64.toolchain.cmake -S ./SPIRV-Tools -B ./build.spirv-tools.rpi -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install.rpi
cmake --build build.spirv-tools.rpi -j$(($(nproc)))
cmake --build build.spirv-tools.rpi -t install

# SPIRV-Headers
[ -e ./install.rpi/include/spirv-tools/spirv ] || ln -s ../../../SPIRV-Headers/include/spirv install.rpi/include/spirv-tools/

cp tvm/cmake/config.cmake build.tvm.rpi
sed -i \
    -e 's/USE_LIBBACKTRACE AUTO/USE_LIBBACKTRACE OFF/' \
    -e 's/USE_VULKAN OFF/USE_VULKAN ON/' \
    -e "s|USE_KHRONOS_SPIRV OFF|USE_KHRONOS_SPIRV ${PWD}/install.rpi|" \
    -e 's/USE_OPENCL OFF/USE_OPENCL ON/' \
    -e 's/USE_CPP_RPC OFF/USE_CPP_RPC ON/' \
    build.tvm.rpi/config.cmake
cmake --toolchain $PWD/aarch64.toolchain.cmake -B ./build.tvm.rpi -S ./tvm -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build.tvm.rpi -j$(($(nproc))) -t tvm_rpc
cmake -E copy_if_different build.tvm.rpi/tvm_rpc install.rpi/bin
cmake -E copy_if_different build.tvm.rpi/libtvm_runtime.so install.rpi/lib