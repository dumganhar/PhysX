#!/bin/bash

set -e

if [ -n "$EMSDK" ]; then
    echo "EMSDK=$EMSDK"
else
    echo "[ERROR] EMSDK env variable is not set!"
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PHYSX_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../physx" && pwd )"
export PM_PxShared_PATH="$PHYSX_ROOT_DIR/../pxshared"
export PM_CMakeModules_PATH="$PHYSX_ROOT_DIR/../externals/cmakemodules"
export PM_opengllinux_PATH="$PHYSX_ROOT_DIR/../externals/opengl-linux"
export PM_TARGA_PATH="$PHYSX_ROOT_DIR/../externals/targa"
export PM_CGLINUX_PATH="$PHYSX_ROOT_DIR/../externals/cg-linux"
export PM_GLEWLINUX_PATH="$PHYSX_ROOT_DIR/../externals/glew-linux"
export PM_PATHS="$PM_opengllinux_PATH;$PM_TARGA_PATH;$PM_CGLINUX_PATH;$PM_GLEWLINUX_PATH"

rm -rf build
mkdir build
cd build



emcmake cmake ../../physx/source/compiler/cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja \
    -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -I${EMSDK}/upstream/emscripten/system/include -I${EMSDK}/upstream/include/c++/v1" \
    -DTARGET_BUILD_PLATFORM=emscripten \
    -DPX_GENERATE_STATIC_LIBRARIES=ON \
    -DBUILD_WASM=ON \
    -DPX_OUTPUT_LIB_DIR="$CURRENT_DIR/lib" \
    -DPX_OUTPUT_BIN_DIR="$CURRENT_DIR/bin"

cp ./compile_commands.json ../..
cd ..
rm -rf build
