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

add_subdirectory(Targets)
export(PACKAGE LibWebRTC)
