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

set(GENERATE_BUILD_DEPENDENCY libwebrtc_patch)
if(NOT BUILD_EXAMPLES)
    set(GENERATE_BUILD_DEPENDENCY libwebrtc_links)
endif(NOT BUILD_EXAMPLES)

set(GENERATE_COMMAND
        ${LIBWEBRTC_ENV_COMMAND} gn gen out/Default --args='${LIBWEBRTC_GEN_ARGS}')

add_libwebrtc_command(libwebrtc_generate_build
        ${CMAKE_BINARY_DIR}/Nevermind
        "${GENERATE_COMMAND}"
        ${CMAKE_BINARY_DIR}/src
        "Generate build files"
        ${GENERATE_BUILD_DEPENDENCY}
)

#
# Revert examples
#

if(NOT BUILD_EXAMPLES)
    set(PATCH_COMMAND sed -i "s/'include_examples%': 0/'include_examples%': 1/g" src/all.gyp)

    add_libwebrtc_command(libwebrtc_revert
            None
            "${PATCH_COMMAND}"
            ${CMAKE_BINARY_DIR}
            "Reverting build definitions"
            libwebrtc_generate_build
    )
endif(NOT BUILD_EXAMPLES)

#
# Run ninja
#

set(NINJA_DEPENDENCY libwebrtc_generate_build)
if(NOT BUILD_EXAMPLES)
    set(GENERATE_BUILD_DEPENDENCY libwebrtc_revert)
endif(NOT BUILD_EXAMPLES)

set(BUILD_WEBRTC_COMMAND
        ${LIBWEBRTC_ENV_COMMAND} ninja -C out/Default libjingle_peerconnection)

add_libwebrtc_command(libwebrtc_build
        ${CMAKE_BINARY_DIR}/src/out/Default/obj/root.stamp
        "${BUILD_WEBRTC_COMMAND}"
        ${CMAKE_BINARY_DIR}/src
        "Build WebRTC"
        ${NINJA_DEPENDENCY}
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