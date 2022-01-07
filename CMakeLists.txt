cmake_minimum_required(VERSION 3.3)
project(libwebrtc)

#
# Allow the use of IN_LIST operand
cmake_policy(SET CMP0057 NEW)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

find_package(Git REQUIRED)

include(FindLibraries)
include(Version)
include(Options)
include(TargetOsAndCpu)

if (HAS_OWN_DEPOT_TOOLS)
  find_package(DepotTools REQUIRED)
endif (HAS_OWN_DEPOT_TOOLS)

if (NOT WIN32)
  find_package(PythonInterp 2.7 REQUIRED)
endif (NOT WIN32)

include(ExternalProject)

if (NOT HAS_OWN_DEPOT_TOOLS)
  if (WIN32)
    set(GCLIENT_EXECUTABLE ${CMAKE_BINARY_DIR}/depot_tools/src/depot-tools/gclient.bat)
  else (WIN32)
    set(GCLIENT_EXECUTABLE ${CMAKE_BINARY_DIR}/depot_tools/src/depot-tools/gclient)
  endif (WIN32)

  ExternalProject_Add(
      depot-tools

      GIT_REPOSITORY https://chromium.googlesource.com/chromium/tools/depot_tools
      GIT_TAG main

      PREFIX ${CMAKE_BINARY_DIR}/depot_tools

      CONFIGURE_COMMAND ""
      UPDATE_COMMAND ""
      PATCH_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ""
  )

  set(_NEXT_DEPENDS depot-tools)
  set(DEPOT_TOOLS_PATH ${CMAKE_BINARY_DIR}/depot_tools/src/depot-tools)
endif (NOT HAS_OWN_DEPOT_TOOLS)

set(_WEBRTC_CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_MODULE_PATH:PATH=${CMAKE_MODULE_PATH}
    -DDEPOT_TOOLS_PATH:PATH=${DEPOT_TOOLS_PATH}
    -DGCLIENT_EXECUTABLE:PATH=${GCLIENT_EXECUTABLE}
    -DHAS_OWN_DEPOT_TOOLS:PATH=${HAS_OWN_DEPOT_TOOLS}
    -DTARGET_CPU=${TARGET_CPU}
    -DTARGET_OS=${TARGET_OS}
    -DWEBRTC_PARENT_DIR:PATH=${CMAKE_BINARY_DIR}/webrtc)

if (BUILD_TESTS)
  set(_WEBRTC_CMAKE_ARGS ${_WEBRTC_CMAKE_ARGS} -DBUILD_TESTS=${BUILD_TESTS})
endif (BUILD_TESTS)

if (WEBRTC_BRANCH_HEAD)
  set(_WEBRTC_CMAKE_ARGS ${_WEBRTC_CMAKE_ARGS} -DWEBRTC_BRANCH_HEAD=${WEBRTC_BRANCH_HEAD})
endif (WEBRTC_BRANCH_HEAD)

if (WEBRTC_REVISION)
  set(_WEBRTC_CMAKE_ARGS ${_WEBRTC_CMAKE_ARGS} -DWEBRTC_REVISION=${WEBRTC_REVISION})
endif (WEBRTC_REVISION)

ExternalProject_Add(
    webrtc-src

    DEPENDS ${_NEXT_DEPENDS}
    GIT_REPOSITORY https://chromium.googlesource.com/external/webrtc

    PREFIX ${CMAKE_BINARY_DIR}/webrtc
    BINARY_DIR ${CMAKE_BINARY_DIR}/webrtc/build
    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/webrtc/src
    SOURCE_DIR ${CMAKE_BINARY_DIR}/webrtc/src
    STAMP_DIR ${CMAKE_BINARY_DIR}/webrtc/stamp
    TMP_DIR ${CMAKE_BINARY_DIR}/webrtc/tmp

    PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/webrtc/CMakeLists.txt.in ${CMAKE_BINARY_DIR}/webrtc/src/CMakeLists.txt
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""

    CMAKE_ARGS
    ${_WEBRTC_CMAKE_ARGS}
)

if (MSVC OR XCODE)
  set(_CONFIG $<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>$<$<CONFIG:RelWithDebInfo>:Release>$<$<CONFIG:MinSizeRel>:Release>)
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
  set(_CONFIG Debug)
else (MSVC OR XCODE)
  set(_CONFIG Release)
endif (MSVC OR XCODE)

ExternalProject_Add(
    libwebrtc
    DEPENDS webrtc-src

    INSTALL_DIR ${CMAKE_BINARY_DIR}
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/libwebrtc
    BINARY_DIR ${CMAKE_BINARY_DIR}/libwebrtc

    CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}
    -DCMAKE_MODULE_PATH:PATH=${CMAKE_MODULE_PATH}
    -DINSTALL_CMAKE_DIR:PATH=${CMAKE_BINARY_DIR}/lib/cmake/LibWebRTC
    -DTARGET_OS:STRING=${TARGET_OS}
    -DWEBRTC_OUTPUT_DIR:PATH=${CMAKE_BINARY_DIR}/webrtc/src/out/${_CONFIG}
    -DWEBRTC_SOURCE_DIR:PATH=${CMAKE_BINARY_DIR}/webrtc/src/webrtc
)

if (BUILD_SAMPLE)
  ExternalProject_Add(
      sample
      DEPENDS libwebrtc
      SOURCE_DIR ${CMAKE_SOURCE_DIR}/sample
      INSTALL_COMMAND ""

      CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  )
endif (BUILD_SAMPLE)

include(Install)
include(Package)

export(PACKAGE LibWebRTC)
