##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##  * Neither the name of NVIDIA CORPORATION nor the names of its
##    contributors may be used to endorse or promote products derived
##    from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
## EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
## CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
## EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
## PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
## OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## Copyright (c) 2018-2019 NVIDIA Corporation. All rights reserved.

SET(EMSCRIPTEN_USE_ASSERTIONS "0")
# SET(BUILD_WASM "True")
# SET(BUILD_CMD "-s EXPORT_NAME=PHYSX --bind -DNDEBUG -O3 -std=c++17 -s NO_EXIT_RUNTIME=1 -s NO_FILESYSTEM=1 -s MODULARIZE=1 -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 ")
if(${BUILD_WASM})
	SET(EMSCRIPTEN_BASE_OPTIONS "--bind -O3 -s MODULARIZE=1 -s EXPORT_NAME=PHYSX -s ALLOW_MEMORY_GROWTH=1 -s ENVIRONMENT=web,worker -s WASM=1") # -s TOTAL_MEMORY=33554432 -s BINARYEN_IGNORE_IMPLICIT_TRAPS=1
else()
	SET(EMSCRIPTEN_BASE_OPTIONS "--bind -O3 -s MODULARIZE=1 -s EXPORT_NAME=PHYSX -s ALLOW_MEMORY_GROWTH=1 -s ENVIRONMENT=web,worker -s WASM=0 -s SINGLE_FILE=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s DYNAMIC_EXECUTION=0") # -s AGGRESSIVE_VARIABLE_ELIMINATION=1 -s ELIMINATE_DUPLICATE_FUNCTIONS=1 -s LEGACY_VM_SUPPORT=1 -s TOTAL_MEMORY=33554432
endif()


SET(LL_SOURCE_DIR ${PHYSX_SOURCE_DIR}/physxwebbindings/src)

SET(PHYSX_WEB_BINDINGS_INCLUDES
	${NVTOOLSEXT_INCLUDE_DIRS}
)

SET(PHYSX_WEB_BINDINGS_OBJECT_FILES
	$<TARGET_OBJECTS:LowLevel>
	$<TARGET_OBJECTS:LowLevelAABB>
	$<TARGET_OBJECTS:LowLevelDynamics>
	$<TARGET_OBJECTS:PhysXTask>
	$<TARGET_OBJECTS:SceneQuery>
	$<TARGET_OBJECTS:SimulationController>	
)

SET(PHYSX_WEB_BINDINGS_SRC_FILES)

SET(PHYSX_WEB_BINDINGS_LIBTYPE STATIC)
SET(PXPHYSX_LIBTYPE_DEFS 
	PX_PHYSX_STATIC_LIB;
)	

SET(PHYSX_WEB_BINDINGS_COMPILE_DEFS
	# Common to all configurations
	${PHYSX_EMSCRIPTEN_COMPILE_DEFS};${PXPHYSX_LIBTYPE_DEFS};${PHYSX_GPU_SHARED_LIB_NAME_DEF};${PXPHYSX_GPU_DEFS}

	$<$<CONFIG:debug>:${PHYSX_EMSCRIPTEN_DEBUG_COMPILE_DEFS};>
	$<$<CONFIG:checked>:${PHYSX_EMSCRIPTEN_CHECKED_COMPILE_DEFS};>
	$<$<CONFIG:profile>:${PHYSX_EMSCRIPTEN_PROFILE_COMPILE_DEFS};>
	$<$<CONFIG:release>:${PHYSX_EMSCRIPTEN_RELEASE_COMPILE_DEFS};>
)

SET(PHYSX_WEB_BINDINGS_LINK_FLAGS " ")
SET(PHYSX_WEB_BINDINGS_LINK_FLAGS_DEBUG " ")
SET(PHYSX_WEB_BINDINGS_LINK_FLAGS_CHECKED " ")
SET(PHYSX_WEB_BINDINGS_LINK_FLAGS_PROFILE " ")
SET(PHYSX_WEB_BINDINGS_LINK_FLAGS_RELEASE " ")

SET(PHYSX_WEB_BINDINGS_LINKED_LIBS dl)

SET(CMAKE_STATIC_LIBRARY_SUFFIX ".bc")

SET(PHYSX_WEB_BINDINGS_SOURCE
	${LL_SOURCE_DIR}/PxWebBindings.cpp
)
SOURCE_GROUP(src FILES ${PHYSX_WEB_BINDINGS_SOURCE})

ADD_EXECUTABLE(PhysXWebBindings ${PHYSX_WEB_BINDINGS_SOURCE}
)

SET_TARGET_PROPERTIES(PhysXWebBindings PROPERTIES
	OUTPUT_NAME PhysXWebBindings
)

TARGET_COMPILE_DEFINITIONS(PhysXWebBindings
	PRIVATE ${PHYSX_WEB_BINDINGS_COMPILE_DEFS}
)


SET_TARGET_PROPERTIES(PhysXWebBindings PROPERTIES
	LINK_FLAGS "${EMSCRIPTEN_BASE_OPTIONS} -s ASSERTIONS=${EMSCRIPTEN_USE_ASSERTIONS}"
)

TARGET_LINK_LIBRARIES(PhysXWebBindings
	PUBLIC PhysX PhysXCommon PhysXFoundation PhysXExtensions PhysXCooking #PhysXVehicle PhysXCharacterKinematic 
	# PUBLIC PhysX PhysXCharacterKinematic PhysXCommon PhysXCooking PhysXExtensions PhysXFoundation PhysXVehicle 
	# PUBLIC PhysXCharacterKinematic PhysXCooking PhysXExtensions PhysXVehicle
)
GET_TARGET_PROPERTY(PHYSXFOUNDATION_INCLUDES PhysXFoundation INTERFACE_INCLUDE_DIRECTORIES)

TARGET_INCLUDE_DIRECTORIES(PhysXWebBindings 
	PRIVATE ${PHYSX_ROOT_DIR}/include
	PRIVATE ${PHYSXFOUNDATION_INCLUDES}
	PRIVATE ${PHYSX_SOURCE_DIR}/common/include
	PRIVATE ${EMSCRIPTEN_ROOT_PATH}/system/include
)

if(${BUILD_WASM})
	set_target_properties(PhysXWebBindings PROPERTIES OUTPUT_NAME "physx.${CMAKE_BUILD_TYPE}.wasm")
else()
	set_target_properties(PhysXWebBindings PROPERTIES OUTPUT_NAME "physx.${CMAKE_BUILD_TYPE}.asm")
endif()

SET_TARGET_PROPERTIES(PhysXWebBindings PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
