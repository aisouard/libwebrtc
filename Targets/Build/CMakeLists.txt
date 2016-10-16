include(Common)

#
# Generate build files
#

set(LIBWEBRTC_GEN_ARGS use_gold=false)

if (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} is_debug=false)
endif (NOT CMAKE_BUILD_TYPE MATCHES DEBUG)

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

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBWEBRTC_INSTALL_LIB_DIR})

set(MERGE_COMMAND
    python ${CMAKE_SOURCE_DIR}/merge_libs_wrapper.py src/out/Default ${LIBWEBRTC_LIBRARY_PATH})

add_libwebrtc_command(libwebrtc_merge
                      ${LIBWEBRTC_LIBRARY_PATH}
                      "${MERGE_COMMAND}"
                      ${CMAKE_BINARY_DIR}
                      "Merging libraries into ${LIBWEBRTC_LIBRARY_NAME}"
                      libwebrtc_build)
