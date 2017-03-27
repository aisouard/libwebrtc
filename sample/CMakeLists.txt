cmake_minimum_required(VERSION 3.3)
project(sample)

find_package(LibWebRTC REQUIRED)
include(${LIBWEBRTC_USE_FILE})

set(SOURCE_FILES main.cpp)
add_executable(sample ${SOURCE_FILES})
target_link_libraries(sample ${LIBWEBRTC_LIBRARIES})

set(_STAMP_FILE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/check-sample-done)
add_custom_command(
    OUTPUT ${_STAMP_FILE}
    COMMENT "Run generated sample"
    COMMAND sample
    COMMAND ${CMAKE_COMMAND} -E touch ${_STAMP_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(check-sample ALL DEPENDS ${_STAMP_FILE})
add_dependencies(check-sample sample)
