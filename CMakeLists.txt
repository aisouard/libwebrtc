cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0057 NEW)
project(libwebrtc)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

if (CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES Debug Release)
endif (CMAKE_CONFIGURATION_TYPES)

find_package(Git REQUIRED)
if (WIN32)
  set(PYTHON_EXECUTABLE ${CMAKE_SOURCE_DIR}/depot_tools/python.bat)
else (WIN32)
  find_package(PythonInterp REQUIRED)
endif (WIN32)
find_package(DepotTools REQUIRED)

#
# Options
#

option(BUILD_TESTS "Build test binaries" OFF)
option(BUILD_SAMPLES "Build samples binaries" OFF)
set(NINJA_ARGS "" CACHE STRING "Ninja arguments to pass before compiling WebRTC")

include(LibWebRTCSubsystem)
include(LibWebRTCVersion)

#
# Directories
#

if (NOT LIBWEBRTC_INSTALL_BIN_DIR)
  set(LIBWEBRTC_INSTALL_BIN_DIR "bin")
endif ()
if (NOT LIBWEBRTC_INSTALL_LIB_DIR)
  set(LIBWEBRTC_INSTALL_LIB_DIR "lib")
endif ()
if (NOT LIBWEBRTC_INSTALL_DATA_DIR)
  set(LIBWEBRTC_INSTALL_DATA_DIR "share")
endif ()
if (NOT LIBWEBRTC_INSTALL_INCLUDE_DIR)
  set(LIBWEBRTC_INSTALL_INCLUDE_DIR "include")
endif ()

set(LIBWEBRTC_LIBRARY_NAME ${CMAKE_STATIC_LIBRARY_PREFIX}webrtc${CMAKE_STATIC_LIBRARY_SUFFIX})
set(LIBWEBRTC_LIBRARY_PATH ${CMAKE_BINARY_DIR}/${LIBWEBRTC_INSTALL_LIB_DIR}/${LIBWEBRTC_LIBRARY_NAME})

set(LIBWEBRTC_BUILD_ROOT ${CMAKE_SOURCE_DIR}/src/out/Default)
add_subdirectory(Targets)

if (BUILD_SAMPLES)
  add_subdirectory(Samples)
endif (BUILD_SAMPLES)
