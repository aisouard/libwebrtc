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
include(TargetOsAndCpu)

add_subdirectory(Targets)
export(PACKAGE LibWebRTC)
