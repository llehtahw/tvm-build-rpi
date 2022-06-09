set -e
set -x

mkdir -p build.host
cd build.host
cp ../tvm/cmake/config.cmake ./
sed -i \
    -e 's/USE_LLVM OFF/USE_LLVM llvm-config/' \
    -e 's/USE_OPENCL OFF/USE_OPENCL ON/' \
    -e 's/USE_VULKAN OFF/USE_VULKAN ON/' \
    -e 's/USE_LIBBACKTRACE AUTO/USE_LIBBACKTRACE OFF/' \
    config.cmake

cmake ../tvm -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(($(nproc)))
cd ..
make cython
pip3 setup.py install
rm build.host -rf