cmake_minimum_required(VERSION 3.0)
project(libwebrtc)

set(_OBJ_EXT ${CMAKE_CXX_OUTPUT_EXTENSION})

file(GLOB_RECURSE _OBJ_FILES
     ${WEBRTC_OUTPUT_DIR}/obj/*${_OBJ_EXT})

if (NOT _OBJ_EXT STREQUAL ".o")
  file(GLOB_RECURSE _OBJ_FILES_ASM
       ${WEBRTC_OUTPUT_DIR}/obj/*.o)
  list(APPEND _OBJ_FILES ${_OBJ_FILES_ASM})
endif (NOT _OBJ_EXT STREQUAL ".o")

file(GLOB_RECURSE _OBJ_EXCLUDED
     ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/gen*/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/re2c/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/yasm/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/third_party/protobuf/protoc/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/third_party/protobuf/protobuf_full/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/webrtc/examples/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/webrtc/tools/*${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/webrtc/modules/video_capture/video_capture/video_capture_external${_OBJ_EXT}
     ${WEBRTC_OUTPUT_DIR}/obj/webrtc/modules/video_capture/video_capture/device_info_external${_OBJ_EXT})

list(LENGTH _OBJ_EXCLUDED _OBJ_EXCLUDED_LEN)
if (${_OBJ_EXCLUDED_LEN} GREATER "0")
  list(REMOVE_ITEM _OBJ_FILES ${_OBJ_EXCLUDED})
endif ()

add_library(webrtc ${LIBRARY_TYPE} ${_OBJ_FILES})

set_source_files_properties(${_OBJ_FILES} PROPERTIES
                            EXTERNAL_OBJECT true
                            GENERATED true)

set_target_properties(webrtc PROPERTIES
                      LINKER_LANGUAGE C
                      LIBRARY_OUTPUT_DIRECTORY ${WEBRTC_OUTPUT_DIR})

#
# Install headers
install(DIRECTORY ${WEBRTC_SOURCE_DIR}
        DESTINATION "include"
        FILES_MATCHING PATTERN "*.h")

install(FILES ${CMAKE_INSTALL_PREFIX}/libwebrtc.h
        DESTINATION "include/libwebrtc")

#
# Install library
#
install(TARGETS webrtc
        DESTINATION "lib"
        COMPONENT Libraries)