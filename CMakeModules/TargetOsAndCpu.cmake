include(CheckSymbolExists)

#
# Target OS
set(TARGET_OS "" CACHE STRING "Target OS, used as --target_os argument")
set(TARGET_OS_LIST android chromeos ios linux nacl mac win)

if (TARGET_OS STREQUAL "")
  if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(TARGET_OS "linux")
  elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(TARGET_OS "mac")
  elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    set(TARGET_OS "win")
  endif ()
endif (TARGET_OS STREQUAL "")

if (NOT ${TARGET_OS} IN_LIST TARGET_OS_LIST)
  message(FATAL_ERROR "Unknown value '${TARGET_OS}' for variable TARGET_OS, options are: ${TARGET_OS_LIST}")
endif (NOT ${TARGET_OS} IN_LIST TARGET_OS_LIST)

#
# Target CPU
function(detect_current_arch)
  if (WIN32)
    check_symbol_exists("_M_X64" "" ARCH_X64)
    if (NOT ARCH_X64)
      check_symbol_exists("_M_AMD64" "" ARCH_X64)
    endif (NOT ARCH_X64)
    check_symbol_exists("_M_IX86" "" ARCH_X86)
    check_symbol_exists("_M_ARM" "" ARCH_ARM)
    check_symbol_exists("_M_ARM64" "" ARCH_ARM64)
  else (WIN32)
    check_symbol_exists("__i386__" "" ARCH_X86)
    check_symbol_exists("__x86_64__" "" ARCH_X64)
    check_symbol_exists("__arm__" "" ARCH_ARM)
    check_symbol_exists("__aarch64__" "" ARCH_ARM64)
    check_symbol_exists("__mips__" "" ARCH_MIPS)
  endif (WIN32)
endfunction(detect_current_arch)

set(TARGET_CPU "" CACHE STRING "Target CPU, used as --target_cpu argument")
set(TARGET_CPU_LIST x86 x64 arm arm64 mipsel)

if (TARGET_CPU STREQUAL "")
  detect_current_arch()

  if (ARCH_X64)
    set(TARGET_CPU "x64")
  elseif (ARCH_X86)
    set(TARGET_CPU "x86")
  elseif (ARCH_ARM64)
    set(TARGET_CPU "arm64")
  elseif (ARCH_ARM)
    set(TARGET_CPU "arm")
  elseif (ARCH_MIPS)
    set(TARGET_CPU "mipsel")
  else ()
    set(TARGET_CPU ${CMAKE_SYSTEM_PROCESSOR})
  endif (ARCH_X64)
endif (TARGET_CPU STREQUAL "")

if (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)
  message(FATAL_ERROR "Unknown value '${TARGET_CPU}' for variable TARGET_CPU, options are: ${TARGET_CPU_LIST}")
endif (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)

if (APPLE)
  list(APPEND LIBWEBRTC_DEFINITIONS WEBRTC_MAC)
endif (APPLE)

if (UNIX)
  if (TARGET_CPU STREQUAL "x86")
    set(LIBWEBRTC_REQUIRED_CXX_FLAGS "${LIBWEBRTC_REQUIRED_CXX_FLAGS} -m32")
  endif (TARGET_CPU STREQUAL "x86")

  set(LIBWEBRTC_REQUIRED_CXX_FLAGS "${LIBWEBRTC_REQUIRED_CXX_FLAGS} -std=gnu++0x")

  if (CMAKE_USE_PTHREADS_INIT)
    set(LIBWEBRTC_REQUIRED_CXX_FLAGS "${LIBWEBRTC_REQUIRED_CXX_FLAGS} -pthread")
  endif ()

  if (CMAKE_BUILD_TYPE MATCHES Debug)
    list(APPEND LIBWEBRTC_DEFINITIONS _GLIBCXX_DEBUG=1 _DEBUG=1)
  endif (CMAKE_BUILD_TYPE MATCHES Debug)
  list(APPEND LIBWEBRTC_DEFINITIONS WEBRTC_POSIX _GLIBCXX_USE_CXX11_ABI=0)
elseif (WIN32)
  set(LIBWEBRTC_REQUIRED_C_FLAGS_DEBUG "/MTd")
  set(LIBWEBRTC_REQUIRED_C_FLAGS_RELEASE "/MT")
  set(LIBWEBRTC_REQUIRED_CXX_FLAGS_DEBUG "/MTd")
  set(LIBWEBRTC_REQUIRED_CXX_FLAGS_RELEASE "/MT")
  list(APPEND LIBWEBRTC_DEFINITIONS WEBRTC_WIN NOMINMAX _CRT_SECURE_NO_WARNINGS)
endif (UNIX)

message(STATUS "Building for ${TARGET_OS} (${TARGET_CPU})")
