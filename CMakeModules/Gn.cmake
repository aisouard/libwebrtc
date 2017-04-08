set(_GEN_ARGS use_gold=false target_cpu=\\"${TARGET_CPU}\\" target_os=\\"${TARGET_OS}\\" is_component_build=false)

if (MSVC OR XCODE)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=$<$<CONFIG:Debug>:true>$<$<CONFIG:Release>:false>$<$<CONFIG:RelWithDebInfo>:false>$<$<CONFIG:MinSizeRel>:false>)
  set(_NINJA_BUILD_DIR out/$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>$<$<CONFIG:RelWithDebInfo>:Release>$<$<CONFIG:MinSizeRel>:Release>)
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=true)
  set(_NINJA_BUILD_DIR out/Debug)
else (MSVC OR XCODE)
  set(_GEN_ARGS ${_GEN_ARGS} is_debug=false)
  set(_NINJA_BUILD_DIR out/Release)
endif (MSVC OR XCODE)

if (BUILD_TESTS)
  set(_GEN_ARGS ${_GEN_ARGS} rtc_include_tests=true)
else (BUILD_TESTS)
  set(_GEN_ARGS ${_GEN_ARGS} rtc_include_tests=false)
endif (BUILD_TESTS)

if (TARGET_CPU STREQUAL "arm")
  set(_GEN_ARGS ${_GEN_ARGS} arm_version="${ARM_VERSION}")

  if (ARM_ARCH)
    set(_GEN_ARGS ${_GEN_ARGS} arm_arch=\\"${ARM_ARCH}\\")
  endif (ARM_ARCH)

  if (ARM_FPU)
    set(_GEN_ARGS ${_GEN_ARGS} arm_fpu=\\"${ARM_FPU}\\")
  endif (ARM_FPU)

  if (ARM_FLOAT_ABI)
    set(_GEN_ARGS ${_GEN_ARGS} arm_float_abi=\\"${ARM_FLOAT_ABI}\\")
  endif (ARM_FLOAT_ABI)

  if (ARM_TUNE)
    set(_GEN_ARGS ${_GEN_ARGS} arm_tune=\\"${ARM_TUNE}\\")
  endif (ARM_TUNE)

  if (ARM_USE_NEON)
    set(_GEN_ARGS ${_GEN_ARGS} arm_use_neon=true)
  else (ARM_USE_NEON)
    set(_GEN_ARGS ${_GEN_ARGS} arm_use_neon=false)
  endif (ARM_USE_NEON)

  if (ARM_USE_THUMB)
    set(_GEN_ARGS ${_GEN_ARGS} arm_use_thumb=true)
  else (ARM_USE_THUMB)
    set(_GEN_ARGS ${_GEN_ARGS} arm_use_thumb=false)
  endif (ARM_USE_THUMB)
endif (TARGET_CPU STREQUAL "arm")

if (GN_EXTRA_ARGS)
  set(_GEN_ARGS ${_GEN_ARGS} ${GN_EXTRA_ARGS})
endif (GN_EXTRA_ARGS)

if (WIN32)
  set(_GN_EXECUTABLE gn.bat)
else (WIN32)
  set(_GN_EXECUTABLE gn)
endif (WIN32)

set(_GEN_COMMAND ${_GN_EXECUTABLE} gen ${_NINJA_BUILD_DIR} --args=\"${_GEN_ARGS}\")
