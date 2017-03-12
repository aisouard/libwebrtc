cmake_minimum_required(VERSION 3.3)
project(libwebrtc)

#
# Allow the use of IN_LIST operand
cmake_policy(SET CMP0057 NEW)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

find_package(Git REQUIRED)
find_package(DepotTools REQUIRED)

if (WIN32)
  set(PYTHON_EXECUTABLE ${DEPOTTOOLS_PATH}/python.bat)
else (WIN32)
  find_package(PythonInterp REQUIRED)
endif (WIN32)

include(FindLibraries)
include(Version)
include(Options)
include(TargetOsAndCpu)

add_subdirectory(Targets)
export(PACKAGE LibWebRTC)
