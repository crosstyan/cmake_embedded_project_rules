set(TOOLCHAIN csky-unknown-elf)
# Toolchain settings
if(NOT DEFINED TOOLCHAIN_PREFIX)
  set(CMAKE_C_COMPILER ${TOOLCHAIN}-gcc)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN}-g++)
  set(CMAKE_ASM_COMPILER ${TOOLCHAIN}-gcc)
  set(CMAKE_LINKER ${TOOLCHAIN}-gcc)
  set(CMAKE_AR ${TOOLCHAIN}-ar)
  set(CMAKE_OBJCOPY ${TOOLCHAIN}-objcopy)
  set(CMAKE_OBJDUMP ${TOOLCHAIN}-objdump)
else()
  set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
  set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-g++)
  set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc)
  set(CMAKE_LINKER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc)
  set(CMAKE_AR ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-ar)
  set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy)
  set(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objdump)
endif()

set(CMAKE_C_COMPILER_WORKS TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_EXECUTABLE_SUFFIX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

# this makes the test compiles use static library option so that we don't need
# to pre-set linker flags and scripts set(CMAKE_TRY_COMPILE_TARGET_TYPE
# STATIC_LIBRARY)

set(CMAKE_C_FLAGS
    "${MCPU_FLAGS} ${VFPU_FLAGS} -fdata-sections -ffunction-sections"
    CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS
    "${MCPU_FLAGS} ${VFPU_FLAGS} -fdata-sections -ffunction-sections"
    CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS
    "${MCPU_FLAGS} ${VFPU_FLAGS} -x assembler-with-cpp"
    CACHE INTERNAL "asm compiler flags")
set(CMAKE_EXE_LINKER_FLAGS
    "${MCPU_FLAGS} ${VFPU_FLAGS} ${LD_FLAGS} ${SPEC_FLAGS} -Wl,--gc-sections -Wl,--print-memory-usage"
    CACHE INTERNAL "exe link flags")

set(CMAKE_C_FLAGS_DEBUG
    "-Og -g -ggdb3"
    CACHE INTERNAL "c debug compiler flags")
set(CMAKE_CXX_FLAGS_DEBUG
    "-Og -g -ggdb3"
    CACHE INTERNAL "cxx debug compiler flags")
set(CMAKE_ASM_FLAGS_DEBUG
    "-g -ggdb3"
    CACHE INTERNAL "asm debug compiler flags")

set(CMAKE_C_FLAGS_RELEASE
    "-O2"
    CACHE INTERNAL "c release compiler flags")
set(CMAKE_CXX_FLAGS_RELEASE
    "-O2"
    CACHE INTERNAL "cxx release compiler flags")
set(CMAKE_ASM_FLAGS_RELEASE
    ""
    CACHE INTERNAL "asm release compiler flags")

#
# some utility functions
#
function(output_binary_files target_name)
  add_custom_command(
    TARGET "${target_name}"
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Output hex, bin ..."
    COMMAND ${CMAKE_OBJCOPY} -O ihex "${target_name}.elf" "${target_name}.hex"
    COMMAND ${CMAKE_OBJCOPY} -O binary "${target_name}.elf" "${target_name}.bin"
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    VERBATIM)
endfunction()

function(check_compiler_version min_version_required)
  message(CHECK_START "Checking compiler version")
  if(DEFINED CMAKE_C_COMPILER_VERSION)
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS min_version_required)
      message(CHECK_FAIL "failed")
      message(
        FATAL_ERROR
          "Current compiler version is '${CMAKE_C_COMPILER_VERSION}', but we need '${min_version_required}' !!!"
      )
    else()
      message(CHECK_PASS "'${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}'")
    endif()
  else()
    message(CHECK_FAIL
            "Skipped, variable 'CMAKE_C_COMPILER_VERSION' is undefined !")
  endif()
endfunction()
