cmake_minimum_required(VERSION 3.5)
project(libwebrtc)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMakeModules)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

if (WIN32)
  set(LIBWEBRTC_OBJ_EXT obj)
elseif (UNIX AND NOT APPLE)
  set(LIBWEBRTC_OBJ_EXT o)
elseif (APPLE)
  set(LIBWEBRTC_OBJ_EXT o)
endif ()

file(GLOB_RECURSE LIBWEBRTC_OBJ_FILES
     ${LIBWEBRTC_OUTPUT_DIR}/obj/*.${LIBWEBRTC_OBJ_EXT})

file(GLOB_RECURSE LIBWEBRTC_OBJ_EXCLUDED
     ${LIBWEBRTC_OUTPUT_DIR}/obj/third_party/yasm/gen*/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/third_party/yasm/re2c/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/third_party/yasm/yasm/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/third_party/protobuf/protoc/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/third_party/protobuf/protobuf_full/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/webrtc/examples/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/webrtc/tools/*.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/webrtc/modules/video_capture/video_capture/video_capture_external.${LIBWEBRTC_OBJ_EXT}
     ${LIBWEBRTC_OUTPUT_DIR}/obj/webrtc/modules/video_capture/video_capture/device_info_external.${LIBWEBRTC_OBJ_EXT})

list(LENGTH LIBWEBRTC_OBJ_EXCLUDED LIBWEBRTC_OBJ_EXCLUDED_LEN)

if (${LIBWEBRTC_OBJ_EXCLUDED_LEN} GREATER "0")
  list(REMOVE_ITEM LIBWEBRTC_OBJ_FILES ${LIBWEBRTC_OBJ_EXCLUDED})
endif ()

add_library(webrtc STATIC ${LIBWEBRTC_OBJ_FILES})

set_source_files_properties(${LIBWEBRTC_OBJ_FILES} PROPERTIES
                            EXTERNAL_OBJECT true
                            GENERATED true)

set_target_properties(webrtc PROPERTIES
                      LINKER_LANGUAGE C
                      LIBRARY_OUTPUT_DIRECTORY ${LIBWEBRTC_OUTPUT_DIR})

#
# Install headers
#
install(DIRECTORY ${LIBWEBRTC_INCLUDE_DIR}
        DESTINATION "include/libwebrtc"
        FILES_MATCHING PATTERN "*.h")

install(FILES ${CMAKE_INSTALL_PREFIX}/libwebrtc.h
        DESTINATION "include/libwebrtc")

#
# Install library
#
install(TARGETS webrtc
        DESTINATION "lib"
        COMPONENT Libraries)