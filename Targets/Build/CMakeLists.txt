include(Common)

#
# Generate build files
#

set(LIBWEBRTC_GEN_ARGS use_gold=false)

if (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} is_debug=false)
elseif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} is_debug=true)
endif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)

if (WIN32)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
elseif (APPLE)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
elseif (UNIX AND NOT APPLE)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS})
endif (WIN32)

if (NOT BUILD_TESTS)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} rtc_include_tests=false)
endif (NOT BUILD_TESTS)

set(GENERATE_COMMAND gn gen out/Default --args="${LIBWEBRTC_GEN_ARGS}")

add_libwebrtc_command(libwebrtc_generate_build
                      ${CMAKE_BINARY_DIR}/Nevermind
                      "${GENERATE_COMMAND}"
                      ${CMAKE_BINARY_DIR}/src
                      "Generate build files"
                      libwebrtc_links)

#
# Run ninja
#

set(BUILD_WEBRTC_COMMAND
    ninja -C out/Default libjingle_peerconnection field_trial_default metrics_default)

add_libwebrtc_command(libwebrtc_build
                      ${CMAKE_BINARY_DIR}/src/out/Default/obj/root.stamp
                      "${BUILD_WEBRTC_COMMAND}"
                      ${CMAKE_BINARY_DIR}/src
                      "Build WebRTC"
                      libwebrtc_generate_build)

#
# Merge libraries into a single one
#

if (WIN32)
  set(LIBWEBRTC_OBJ_EXT *.obj)
elseif (UNIX AND NOT APPLE)
  set(LIBWEBRTC_OBJ_EXT *.o)
elseif (APPLE)
  set(LIBWEBRTC_OBJ_EXT *.a)
endif (WIN32)

file(GLOB_RECURSE LIBWEBRTC_OBJ_FILES
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/${LIBWEBRTC_OBJ_EXT})

file(GLOB_RECURSE LIBWEBRTC_OBJ_EXCLUDED
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/third_party/yasm/gen*/${LIBWEBRTC_OBJ_EXT}
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/third_party/yasm/re2c/${LIBWEBRTC_OBJ_EXT}
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/third_party/yasm/yasm/${LIBWEBRTC_OBJ_EXT}
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/third_party/protobuf/protoc/${LIBWEBRTC_OBJ_EXT}
     ${CMAKE_BINARY_DIR}/src/out/Default/obj/third_party/protobuf/protobuf_full/${LIBWEBRTC_OBJ_EXT})

list(REMOVE_ITEM LIBWEBRTC_OBJ_FILES ${LIBWEBRTC_OBJ_EXCLUDED})

add_library(webrtc STATIC ${LIBWEBRTC_OBJ_FILES})

set_source_files_properties(${LIBWEBRTC_OBJ_FILES} PROPERTIES
                            EXTERNAL_OBJECT true
                            GENERATED true)

set_target_properties(webrtc PROPERTIES
                      LINKER_LANGUAGE C)

install(TARGETS webrtc
        DESTINATION ${LIBWEBRTC_INSTALL_LIB_DIR}
        COMPONENT Libraries)