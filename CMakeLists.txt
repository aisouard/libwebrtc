cmake_minimum_required(VERSION 3.3)
project(libwebrtc)

#
# Allow the use of IN_LIST operand
cmake_policy(SET CMP0057 NEW)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

include(FindLibraries)
include(Version)
include(Options)

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
set(TARGET_CPU "" CACHE STRING "Target CPU, used as --target_cpu argument")
set(TARGET_CPU_LIST x86 x64 arm arm64 mipsel)

if (TARGET_CPU STREQUAL "")
  include(CheckSymbolExists)
  if (WIN32)
    check_symbol_exists("_M_X64" "" ARCH_X64)
    if (NOT ARCH_X64)
      check_symbol_exists("_M_AMD64" "" ARCH_X64)
	  if (NOT ARCH_X64)
        check_symbol_exists("_M_IX86" "" ARCH_X86)
	    if (NOT ARCH_X86)
          check_symbol_exists("_M_ARM" "" ARCH_ARM)
          check_symbol_exists("_M_ARM64" "" ARCH_ARM64)
        endif (NOT ARCH_X86)
      endif (NOT ARCH_X64)
    endif (NOT ARCH_X64)
  else (WIN32)
    check_symbol_exists("__i386__" "" ARCH_X86)
    check_symbol_exists("__x86_64__" "" ARCH_X64)
    check_symbol_exists("__arm__" "" ARCH_ARM)
    check_symbol_exists("__aarch64__" "" ARCH_ARM64)
  endif (WIN32)
  if (ARCH_X86)
    set(TARGET_CPU "x86")
  elseif (ARCH_X64)
    set(TARGET_CPU "x64")
  else ()
    set(TARGET_CPU ${CMAKE_SYSTEM_PROCESSOR})
  endif (ARCH_X86)
endif (TARGET_CPU STREQUAL "")

if (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)
  message(FATAL_ERROR "Unknown value '${TARGET_CPU}' for variable TARGET_CPU, options are: ${TARGET_CPU_LIST}")
endif (NOT ${TARGET_CPU} IN_LIST TARGET_CPU_LIST)

if (UNIX)
  if (ARCH_X86)
    set(LIBWEBRTC_REQUIRED_CXX_FLAGS "-m32")
  endif (ARCH_X86)
  set(LIBWEBRTC_REQUIRED_CXX_FLAGS "${LIBWEBRTC_REQUIRED_CXX_FLAGS} -std=gnu++0x")
  list(APPEND LIBWEBRTC_DEFINITIONS WEBRTC_POSIX _GLIBCXX_USE_CXX11_ABI=0)
elseif (WIN32)
  set(LIBWEBRTC_REQUIRED_C_FLAGS_DEBUG "/MTd")
  set(LIBWEBRTC_REQUIRED_C_FLAGS_RELEASE "/MT")
  set(LIBWEBRTC_REQUIRED_CXX_FLAGS_DEBUG "/MTd")
  set(LIBWEBRTC_REQUIRED_CXX_FLAGS_RELEASE "/MT")
  list(APPEND LIBWEBRTC_DEFINITIONS WEBRTC_WIN NOMINMAX _CRT_SECURE_NO_WARNINGS)
endif(UNIX)

set(LIBWEBRTC_LIBRARIES webrtc)

add_subdirectory(Targets)
export(PACKAGE LibWebRTC)
