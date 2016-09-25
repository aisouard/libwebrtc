include(Common)

#
# Generate build files
#

set(LIBWEBRTC_GEN_ARGS "")

if(NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(LIBWEBRTC_GEN_ARGS is_debug=false)
endif(NOT CMAKE_BUILD_TYPE MATCHES DEBUG)

if(NOT BUILD_TESTS)
    set(LIBWEBRTC_GEN_ARGS ${LIBWEBRTC_GEN_ARGS} rtc_include_tests=false)
endif(NOT BUILD_TESTS)

set(GENERATE_COMMAND
        ${LIBWEBRTC_ENV_COMMAND} gn gen out/Default --args='${LIBWEBRTC_GEN_ARGS}')

add_libwebrtc_command(libwebrtc_generate_build
        ${CMAKE_BINARY_DIR}/Nevermind
        "${GENERATE_COMMAND}"
        ${CMAKE_BINARY_DIR}/src
        "Generate build files"
        libwebrtc_links
)

#
# Run ninja
#

set(BUILD_WEBRTC_COMMAND
        ${LIBWEBRTC_ENV_COMMAND} ninja -C out/Default libjingle_peerconnection)

add_libwebrtc_command(libwebrtc_build
        ${CMAKE_BINARY_DIR}/src/out/Default/obj/root.stamp
        "${BUILD_WEBRTC_COMMAND}"
        ${CMAKE_BINARY_DIR}/src
        "Build WebRTC"
        libwebrtc_generate_build
)

#
# Merge libraries into a single one
#

set(MERGE_COMMAND
        python webrtc/build/merge_libs.py out/Default ${CMAKE_BINARY_DIR}/${WEBRTC_LIBRARY})

add_libwebrtc_command(libwebrtc_merge
        ${CMAKE_BINARY_DIR}/${WEBRTC_LIBRARY}
        "${MERGE_COMMAND}"
        ${CMAKE_BINARY_DIR}/src
        "Merging libraries into ${WEBRTC_LIBRARY}"
        libwebrtc_build
)