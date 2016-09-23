cmake_minimum_required(VERSION 3.2)
project(libwebrtc)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

find_package(Git REQUIRED)
find_package(DepotTools REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(WEBRTC_CHROMIUM_DEPS git@github.com:aisouard/libwebrtc-chromium-deps.git)

add_subdirectory(Targets)